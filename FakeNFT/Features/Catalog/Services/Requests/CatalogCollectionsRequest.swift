import Foundation

struct CatalogCollectionsRequest: NetworkRequest {
    let page: Int
    let size: Int

    init(page: Int, size: Int) {
        self.page = max(0, page)
        self.size = max(1, size)
    }

    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/collections")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        return components?.url
    }
}
