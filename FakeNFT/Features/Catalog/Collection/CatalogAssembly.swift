import UIKit

final class CatalogAssembly {

    private let onDidSelectCollection: ((CatalogCollection) -> Void)?
    private let networkClient: NetworkClient

    init(
        servicesAssembly: ServicesAssembly,
        onDidSelectCollection: ((CatalogCollection) -> Void)? = nil
    ) {
        self.onDidSelectCollection = onDidSelectCollection
        self.networkClient = servicesAssembly.sharedNetworkClient
    }

    @MainActor
    func build() -> UIViewController {
        let collectionsProvider = makeCollectionsProvider()
        let collectionNftsProvider = makeCollectionNftsProvider()
        let userActionsProvider = makeUserActionsProvider()

        let viewModel = CatalogViewModel(collectionsProvider: collectionsProvider)
        let viewController = CatalogViewController(viewModel: viewModel)

        if let onDidSelectCollection {
            viewModel.onDidSelectCollection = onDidSelectCollection
        } else {
            viewModel.onDidSelectCollection = { [weak viewController] collection in
                guard let navigationController = viewController?.navigationController else { return }
                let detailsAssembly = CatalogCollectionDetailsAssembly(
                    nftsProvider: collectionNftsProvider,
                    userActionsProvider: userActionsProvider
                )
                let detailsViewController = detailsAssembly.build(collection: collection)
                detailsViewController.hidesBottomBarWhenPushed = true
                navigationController.pushViewController(detailsViewController, animated: true)
            }
        }

        return viewController
    }

    private func makeCollectionsProvider() -> CatalogCollectionsProviding {
        CatalogService(networkClient: networkClient)
    }

    private func makeCollectionNftsProvider() -> CatalogCollectionNftsProviding {
        CatalogCollectionNftsService(networkClient: networkClient)
    }

    private func makeUserActionsProvider() -> CatalogUserActionsProviding {
        CatalogUserActionsService(networkClient: networkClient)
    }
}
