import Foundation

struct CatalogProfileRequest: NetworkRequest {
    var endpoint: URL? {
        CatalogRequestFactory.profileURL()
    }
}
