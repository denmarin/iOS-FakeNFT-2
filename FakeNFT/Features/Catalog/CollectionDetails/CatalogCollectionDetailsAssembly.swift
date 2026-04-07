import UIKit

final class CatalogCollectionDetailsAssembly {
    private let nftsProvider: CatalogCollectionNftsProviding

    init(nftsProvider: CatalogCollectionNftsProviding) {
        self.nftsProvider = nftsProvider
    }

    @MainActor
    func build(collection: CatalogCollection) -> UIViewController {
        let viewModel = CatalogCollectionDetailsViewModel(
            collection: collection,
            provider: nftsProvider
        )
        return CatalogCollectionDetailsViewController(viewModel: viewModel)
    }
}
