import UIKit

final class CatalogCollectionDetailsAssembly {
    private let nftsProvider: CatalogCollectionNftsProviding
    private let userActionsProvider: CatalogUserActionsProviding

    init(
        nftsProvider: CatalogCollectionNftsProviding,
        userActionsProvider: CatalogUserActionsProviding
    ) {
        self.nftsProvider = nftsProvider
        self.userActionsProvider = userActionsProvider
    }

    @MainActor
    func build(collection: CatalogCollection) -> UIViewController {
        let viewModel = CatalogCollectionDetailsViewModel(
            collection: collection,
            nftsProvider: nftsProvider,
            userActionsProvider: userActionsProvider
        )
        return CatalogCollectionDetailsViewController(viewModel: viewModel)
    }
}
