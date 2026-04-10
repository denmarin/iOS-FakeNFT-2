import Foundation

@MainActor
final class CatalogCollectionDetailsViewModel {
    private enum Constants {
        static let loadingErrorMessage = "Не удалось загрузить коллекцию NFT. Попробуйте снова."
        static let favoritesSyncErrorMessage = "Не удалось обновить лайки. Попробуйте снова."
        static let cartSyncErrorMessage = "Не удалось обновить корзину. Попробуйте снова."
    }

    let headerViewModel: CatalogCollectionDetailsHeaderViewModel
    var onStateChange: ((CatalogCollectionDetailsViewState) -> Void)?

    private let collection: CatalogCollection
    private let nftsProvider: CatalogCollectionNftsProviding
    private let userActionsProvider: CatalogUserActionsProviding
    private var loadingTask: Task<Void, Never>?
    private var actionsLoadingTask: Task<Void, Never>?
    private var favoriteSyncTask: Task<Void, Never>?
    private var cartSyncTask: Task<Void, Never>?
    private var nfts: [Nft] = []
    private var favoriteIDs: Set<String> = []
    private var cartIDs: Set<String> = []

    init(
        collection: CatalogCollection,
        nftsProvider: CatalogCollectionNftsProviding,
        userActionsProvider: CatalogUserActionsProviding
    ) {
        self.collection = collection
        self.nftsProvider = nftsProvider
        self.userActionsProvider = userActionsProvider
        self.headerViewModel = CatalogCollectionDetailsHeaderViewModel(
            title: collection.name,
            coverImageName: collection.coverImageName,
            description: collection.description,
            authorName: collection.authorName
        )
    }

    deinit {
        loadingTask?.cancel()
        actionsLoadingTask?.cancel()
        favoriteSyncTask?.cancel()
        cartSyncTask?.cancel()
    }

    func viewDidLoad() {
        guard nfts.isEmpty else {
            publishContent()
            return
        }
        loadNfts()
    }

    func retryLoading() {
        if nfts.isEmpty {
            loadNfts()
        } else {
            loadUserActions()
            publishContent()
        }
    }

    func didTapFavorite(for nftID: String) {
        guard nfts.contains(where: { $0.id == nftID }) else { return }
        toggleState(in: &favoriteIDs, for: nftID)
        publishContent()
        enqueueFavoritesSync()
    }

    func didTapCart(for nftID: String) {
        guard nfts.contains(where: { $0.id == nftID }) else { return }
        toggleState(in: &cartIDs, for: nftID)
        publishContent()
        enqueueCartSync()
    }

    private func loadNfts() {
        onStateChange?(.loading)
        loadingTask?.cancel()
        loadUserActions()

        loadingTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await partialNfts in nftsProvider.nftsStream(for: collection) {
                    guard !Task.isCancelled else { return }
                    applyNfts(partialNfts)
                }
            } catch is CancellationError {
                return
            } catch {
                onStateChange?(.failed(message: Constants.loadingErrorMessage))
            }
        }
    }

    private func loadUserActions() {
        actionsLoadingTask?.cancel()
        actionsLoadingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let state = try await userActionsProvider.fetchUserActionsState()
                guard !Task.isCancelled else { return }
                applyUserActionsState(state)
            } catch is CancellationError {
                return
            } catch {
                handleUserActionsLoadingFailure(error)
            }
        }
    }

    private func enqueueFavoritesSync() {
        let ids = favoriteIDs.sorted()
        let previousTask = favoriteSyncTask

        favoriteSyncTask = Task { [weak self] in
            _ = await previousTask?.result
            guard let self, !Task.isCancelled else { return }

            do {
                let remoteLikedIDs = try await userActionsProvider.updateLikedNftIDs(ids)
                guard !Task.isCancelled else { return }
                applyFavoriteIDs(remoteLikedIDs)
            } catch is CancellationError {
                return
            } catch {
                handleUserActionsSyncFailure(message: Constants.favoritesSyncErrorMessage)
            }
        }
    }

    private func enqueueCartSync() {
        let ids = cartIDs.sorted()
        let previousTask = cartSyncTask

        cartSyncTask = Task { [weak self] in
            _ = await previousTask?.result
            guard let self, !Task.isCancelled else { return }

            do {
                let remoteCartIDs = try await userActionsProvider.updateCartNftIDs(ids)
                guard !Task.isCancelled else { return }
                applyCartIDs(remoteCartIDs)
            } catch is CancellationError {
                return
            } catch {
                handleUserActionsSyncFailure(message: Constants.cartSyncErrorMessage)
            }
        }
    }

    private func applyNfts(_ nfts: [Nft]) {
        self.nfts = nfts
        publishContent()
    }

    private func applyUserActionsState(_ state: CatalogUserActionsState) {
        favoriteIDs = state.likedNftIDs
        cartIDs = state.cartNftIDs
        guard !nfts.isEmpty else { return }
        publishContent()
    }

    private func applyFavoriteIDs(_ ids: Set<String>) {
        favoriteIDs = ids
        publishContent()
    }

    private func applyCartIDs(_ ids: Set<String>) {
        cartIDs = ids
        publishContent()
    }

    private func handleUserActionsLoadingFailure(_: Error) {
        // Likes/cart are non-critical for initial content rendering.
        // Keep current state and retry synchronization on the next user action.
    }

    private func handleUserActionsSyncFailure(message: String) {
        loadUserActions()
        onStateChange?(.failed(message: message))
    }

    private func publishContent() {
        let cellModels = nfts.map { nft in
            CatalogCollectionNftCellViewModel(
                id: nft.id,
                name: nft.name,
                imageURL: Self.previewImageURL(from: nft),
                rating: min(max(nft.rating, 0), 5),
                priceText: Self.priceText(from: nft.price),
                isFavorite: favoriteIDs.contains(nft.id),
                isInCart: cartIDs.contains(nft.id)
            )
        }
        onStateChange?(.content(cellModels))
    }

    private static func previewImageURL(from nft: Nft) -> URL? {
        nft.images.first
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
