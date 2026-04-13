import Foundation

struct CatalogNftByIDRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        CatalogRequestFactory.nftURL(id: id)
    }
}
