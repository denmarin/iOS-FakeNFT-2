import Foundation

enum CatalogViewState: Sendable {
    case loading
    case content([CatalogCollectionCellViewModel])
    case empty
    case error(message: String)
}

struct CatalogCollectionCellViewModel: Equatable, Sendable {
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
        static let loadNextPageThreshold = 3
    }

    private struct PaginationState: Sendable {
        let allCollections: [CatalogCollection]
        let seenCollectionIDs: Set<String>
        let nextPage: Int
        let hasNextPage: Bool
    }

    private struct ReloadFallbackState: Sendable {
        let paginationState: PaginationState
        let selectedSortOption: CatalogSortOption?
    }

    var onStateChange: ((CatalogViewState) -> Void)?
    var onPaginationLoadingChange: ((Bool) -> Void)?
    var onPresentSortOptions: (([CatalogSortOption]) -> Void)?
    var onDidSelectCollection: ((CatalogCollection) -> Void)?

    private let collectionsProvider: CatalogCollectionsProviding
    private var loadingTask: Task<Void, Never>?
    private var allCollections: [CatalogCollection] = []
    private var seenCollectionIDs: Set<String> = []
    private var selectedSortOption: CatalogSortOption?
    private var nextPage = 0
    private var hasNextPage = true
    private var isPageLoading = false
    private var loadingSequence = 0
    private var reloadFallbackState: ReloadFallbackState?

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
            publishCollections()
            return
        }
        loadFirstPage(showFullScreenLoader: true, fallbackSortOption: nil)
    }

    func retryLoading() {
        loadFirstPage(showFullScreenLoader: true, fallbackSortOption: nil)
    }

    func refreshCollections() {
        loadFirstPage(showFullScreenLoader: false, fallbackSortOption: nil)
    }

    func didTapSort() {
        onPresentSortOptions?(CatalogSortOption.allCases)
    }

    func didSelectSortOption(_ option: CatalogSortOption) {
        guard selectedSortOption != option else { return }
        let previousSortOption = selectedSortOption
        selectedSortOption = option
        loadFirstPage(
            showFullScreenLoader: allCollections.isEmpty,
            fallbackSortOption: previousSortOption
        )
    }

    func didSelectCollection(at index: Int) {
        guard allCollections.indices.contains(index) else { return }
        onDidSelectCollection?(allCollections[index])
    }

    func didDisplayCollection(at index: Int) {
        guard shouldLoadNextPage(whenDisplaying: index) else { return }
        loadNextPage()
    }

    private func loadFirstPage(showFullScreenLoader: Bool, fallbackSortOption: CatalogSortOption?) {
        loadingTask?.cancel()
        if showFullScreenLoader || allCollections.isEmpty {
            reloadFallbackState = nil
        } else {
            reloadFallbackState = ReloadFallbackState(
                paginationState: currentPaginationState(),
                selectedSortOption: fallbackSortOption ?? selectedSortOption
            )
        }
        resetPagination()
        if showFullScreenLoader {
            onStateChange?(.loading)
        }
        loadNextPage()
    }

    private func loadNextPage() {
        guard hasNextPage, !isPageLoading else { return }

        let requestedPage = nextPage
        let sortBy = selectedSortOption?.serverSort
        let shouldShowPaginationLoader = requestedPage > 0
        loadingSequence += 1
        let sequence = loadingSequence
        isPageLoading = true
        if shouldShowPaginationLoader {
            onPaginationLoadingChange?(true)
        }

        loadingTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if self.loadingSequence == sequence {
                    self.isPageLoading = false
                    if shouldShowPaginationLoader {
                        self.onPaginationLoadingChange?(false)
                    }
                }
            }

            do {
                let page = try await self.collectionsProvider.fetchCollectionsPage(
                    page: requestedPage,
                    sortBy: sortBy
                )
                guard !Task.isCancelled, self.loadingSequence == sequence else { return }
                self.consumePage(page, requestedPage: requestedPage)
            } catch is CancellationError {
                return
            } catch {
                guard self.loadingSequence == sequence else { return }
                self.handleLoadError()
            }
        }
    }

    private func consumePage(_ page: CatalogCollectionsPage, requestedPage: Int) {
        reloadFallbackState = nil
        nextPage = requestedPage + 1
        hasNextPage = page.hasNextPage

        let uniqueCollections = page.collections.filter { seenCollectionIDs.insert($0.id).inserted }
        if !uniqueCollections.isEmpty {
            allCollections.append(contentsOf: uniqueCollections)
            publishCollections()
            return
        }

        if allCollections.isEmpty {
            onStateChange?(.empty)
        }
    }

    private func publishCollections() {
        guard !allCollections.isEmpty else {
            onStateChange?(.empty)
            return
        }

        let cellModels = allCollections.map { collection in
            CatalogCollectionCellViewModel(
                id: collection.id,
                name: collection.name,
                coverImageName: collection.coverImageName,
                nftCount: collection.nftCount
            )
        }
        onStateChange?(.content(cellModels))
    }

    private func shouldLoadNextPage(whenDisplaying index: Int) -> Bool {
        guard hasNextPage, !isPageLoading, !allCollections.isEmpty else { return false }
        let thresholdIndex = max(allCollections.count - Constants.loadNextPageThreshold, 0)
        return index >= thresholdIndex
    }

    private func resetPagination() {
        allCollections = []
        seenCollectionIDs = []
        nextPage = 0
        hasNextPage = true
        isPageLoading = false
        onPaginationLoadingChange?(false)
    }

    private func handleLoadError() {
        if let fallbackState = reloadFallbackState {
            applyPaginationState(fallbackState.paginationState)
            selectedSortOption = fallbackState.selectedSortOption
            reloadFallbackState = nil
            publishCollections()
            return
        }

        if allCollections.isEmpty {
            onStateChange?(.error(message: Constants.loadingErrorMessage))
        }
    }

    private func currentPaginationState() -> PaginationState {
        PaginationState(
            allCollections: allCollections,
            seenCollectionIDs: seenCollectionIDs,
            nextPage: nextPage,
            hasNextPage: hasNextPage
        )
    }

    private func applyPaginationState(_ state: PaginationState) {
        allCollections = state.allCollections
        seenCollectionIDs = state.seenCollectionIDs
        nextPage = state.nextPage
        hasNextPage = state.hasNextPage
        isPageLoading = false
    }
}

private extension CatalogSortOption {
    var serverSort: CatalogCollectionsSort {
        switch self {
        case .byName:
            .byNameAscending
        case .byNftCount:
            .byNftCountDescending
        }
    }
}
