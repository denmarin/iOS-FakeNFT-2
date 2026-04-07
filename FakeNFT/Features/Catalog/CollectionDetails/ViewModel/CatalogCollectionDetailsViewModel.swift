import Foundation

@MainActor
final class CatalogCollectionDetailsViewModel {
    let headerViewModel: CatalogCollectionDetailsHeaderViewModel
    var onStateChange: ((CatalogCollectionDetailsViewState) -> Void)?

    private let collection: CatalogCollection
    private let provider: CatalogCollectionNftsProviding
    private var loadingTask: Task<Void, Never>?
    private var nfts: [Nft] = []
    private var favoriteIDs: Set<String> = []
    private var cartIDs: Set<String> = []

    init(
        collection: CatalogCollection,
        provider: CatalogCollectionNftsProviding
    ) {
        self.collection = collection
        self.provider = provider
        self.headerViewModel = CatalogCollectionDetailsHeaderViewModel(
            title: collection.name,
            coverImageName: collection.coverImageName,
            description: collection.description,
            authorName: collection.authorName
        )
    }

    deinit {
        loadingTask?.cancel()
    }

    func viewDidLoad() {
        guard nfts.isEmpty else {
            publishContent()
            return
        }
        loadNfts()
    }

    func didTapFavorite(for nftID: String) {
        guard nfts.contains(where: { $0.id == nftID }) else { return }
        toggleState(in: &favoriteIDs, for: nftID)
        publishContent()
    }

    func didTapCart(for nftID: String) {
        guard nfts.contains(where: { $0.id == nftID }) else { return }
        toggleState(in: &cartIDs, for: nftID)
        publishContent()
    }

    private func loadNfts() {
        onStateChange?(.loading)
        loadingTask?.cancel()

        loadingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let fetchedNfts = try await provider.fetchNfts(for: collection)
                guard !Task.isCancelled else { return }
                nfts = fetchedNfts
                publishContent()
            } catch is CancellationError {
                return
            } catch {
                onStateChange?(
                    .failed(message: "Не удалось загрузить коллекцию NFT. Попробуйте снова.")
                )
            }
        }
    }

    private func publishContent() {
        let cellModels = nfts.map { nft in
            CatalogCollectionNftCellViewModel(
                id: nft.id,
                name: nft.name,
                imageURL: nft.images.first,
                rating: min(max(nft.rating, 0), 5),
                priceText: Self.priceText(from: nft.price),
                isFavorite: favoriteIDs.contains(nft.id),
                isInCart: cartIDs.contains(nft.id)
            )
        }
        onStateChange?(.content(cellModels))
    }

    private func toggleState(in set: inout Set<String>, for nftID: String) {
        if set.contains(nftID) {
            set.remove(nftID)
        } else {
            set.insert(nftID)
        }
    }

    private static func priceText(from price: Double) -> String {
        let formattedPrice = priceFormatter.string(from: NSNumber(value: price)) ?? String(price)
        return "\(formattedPrice) ETH"
    }

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
