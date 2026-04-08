import UIKit

final class CatalogAssembly {

    private let onDidSelectCollection: ((CatalogCollection) -> Void)?

    init(
        servicesAssembly _: ServicesAssembly,
        onDidSelectCollection: ((CatalogCollection) -> Void)? = nil
    ) {
        self.onDidSelectCollection = onDidSelectCollection
    }

    @MainActor
    func build() -> UIViewController {
        let collectionsProvider = makeCollectionsProvider()
        let collectionNftsProvider = makeCollectionNftsProvider()

        let viewModel = CatalogViewModel(provider: collectionsProvider)
        let viewController = CatalogViewController(viewModel: viewModel)

        if let onDidSelectCollection {
            viewModel.onDidSelectCollection = onDidSelectCollection
        } else {
            viewModel.onDidSelectCollection = { [weak viewController] collection in
                guard let navigationController = viewController?.navigationController else { return }
                let detailsAssembly = CatalogCollectionDetailsAssembly(nftsProvider: collectionNftsProvider)
                let detailsViewController = detailsAssembly.build(collection: collection)
                detailsViewController.hidesBottomBarWhenPushed = true
                navigationController.pushViewController(detailsViewController, animated: true)
            }
        }

        return viewController
    }

    private func makeCollectionsProvider() -> CatalogCollectionsProviding {
        // TODO: replace mock provider with API provider when catalog endpoint is ready.
        return MockCatalogCollectionsProvider(loadingDelay: .milliseconds(650))
    }

    private func makeCollectionNftsProvider() -> CatalogCollectionNftsProviding {
        // TODO: replace mock provider with API provider when collection NFT endpoint is ready.
        return MockCatalogCollectionNftsProvider(loadingDelay: .milliseconds(450))
    }
}
