import Foundation

enum CatalogViewState {
    case loading
    case content([CatalogCollectionCellViewModel])
    case empty
    case error(message: String)
}

struct CatalogCollectionCellViewModel: Equatable {
    let id: String
    let name: String
    let coverImageName: String
    let nftCount: Int

    var formattedNftCount: String {
        "(\(nftCount))"
    }
}

@MainActor
final class CatalogViewModel {
    private enum Constants {
        static let loadingErrorMessage = "Не удалось загрузить каталог. Попробуйте снова."
    }

    var onStateChange: ((CatalogViewState) -> Void)?
    var onPresentSortOptions: (([CatalogSortOption]) -> Void)?
    var onDidSelectCollection: ((CatalogCollection) -> Void)?

    private let collectionsProvider: CatalogCollectionsProviding
    private var loadingTask: Task<Void, Never>?
    private var allCollections: [CatalogCollection] = []
    private var displayedCollections: [CatalogCollection] = []
    private var selectedSortOption: CatalogSortOption?

    init(
        collectionsProvider: CatalogCollectionsProviding
    ) {
        self.collectionsProvider = collectionsProvider
    }

    deinit {
        loadingTask?.cancel()
    }

    func viewDidLoad() {
        guard allCollections.isEmpty else {
            applySortAndPublish()
            return
        }
        loadCollections()
    }

    func retryLoading() {
        loadCollections()
    }

    func didTapSort() {
        onPresentSortOptions?(CatalogSortOption.allCases)
    }

    func didSelectSortOption(_ option: CatalogSortOption) {
        selectedSortOption = option
        applySortAndPublish()
    }

    func didSelectCollection(at index: Int) {
        guard displayedCollections.indices.contains(index) else { return }
        onDidSelectCollection?(displayedCollections[index])
    }

    private func loadCollections() {
        onStateChange?(.loading)
        loadingTask?.cancel()

        loadingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let collections = try await collectionsProvider.fetchCollections { [weak self] partialCollections in
                    guard let self else { return }
                    self.publishCollectionsIfNeeded(partialCollections)
                }
                guard !Task.isCancelled else { return }
                self.publishCollectionsIfNeeded(collections, forcePublishWhenUnchanged: collections.isEmpty)
            } catch is CancellationError {
                return
            } catch {
                if self.allCollections.isEmpty {
                    self.onStateChange?(.error(message: Constants.loadingErrorMessage))
                }
            }
        }
    }

    private func publishCollectionsIfNeeded(
        _ collections: [CatalogCollection],
        forcePublishWhenUnchanged: Bool = false
    ) {
        let shouldPublish = forcePublishWhenUnchanged || allCollections != collections
        allCollections = collections
        guard shouldPublish else { return }
        applySortAndPublish()
    }

    private func applySortAndPublish() {
        if let selectedSortOption {
            displayedCollections = sortCollections(allCollections, by: selectedSortOption)
        } else {
            displayedCollections = allCollections
        }

        guard !displayedCollections.isEmpty else {
            onStateChange?(.empty)
            return
        }

        let cellModels = displayedCollections.map { collection in
            CatalogCollectionCellViewModel(
                id: collection.id,
                name: collection.name,
                coverImageName: collection.coverImageName,
                nftCount: collection.nftCount
            )
        }
        onStateChange?(.content(cellModels))
    }

    private func sortCollections(
        _ collections: [CatalogCollection],
        by option: CatalogSortOption
    ) -> [CatalogCollection] {
        switch option {
        case .byName:
            return collections.sorted(by: Self.compareByName)
        case .byNftCount:
            return collections.sorted(by: Self.compareByNftCount)
        }
    }

    private static func compareByName(lhs: CatalogCollection, rhs: CatalogCollection) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    private static func compareByNftCount(lhs: CatalogCollection, rhs: CatalogCollection) -> Bool {
        if lhs.nftCount == rhs.nftCount {
            return compareByName(lhs: lhs, rhs: rhs)
        }
        return lhs.nftCount > rhs.nftCount
    }
}
