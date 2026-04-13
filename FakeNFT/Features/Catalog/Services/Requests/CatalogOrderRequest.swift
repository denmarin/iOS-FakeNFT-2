import Foundation

struct CatalogOrderRequest: NetworkRequest {
    var endpoint: URL? {
        CatalogRequestFactory.orderURL()
    }
}
