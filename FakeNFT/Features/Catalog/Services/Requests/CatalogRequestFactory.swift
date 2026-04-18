import Foundation

enum CatalogRequestFactory {
    private enum Path {
        static let collections = "/api/v1/collections"
        static let profile = "/api/v1/profile/1"
        static let order = "/api/v1/orders/1"
        static let nft = "/api/v1/nft/"
    }

    static func collectionsComponents() -> URLComponents? {
        URLComponents(string: "\(RequestConstants.baseURL)\(Path.collections)")
    }

    static func profileURL() -> URL? {
        makeURL(path: Path.profile)
    }

    static func orderURL() -> URL? {
        makeURL(path: Path.order)
    }

    static func nftURL(id: String) -> URL? {
        makeURL(path: "\(Path.nft)\(id)")
    }

    private static func makeURL(path: String) -> URL? {
        URL(string: "\(RequestConstants.baseURL)\(path)")
    }
}
