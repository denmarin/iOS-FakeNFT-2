import Foundation

struct CatalogCollectionsRequest: NetworkRequest {
    let page: Int
    let size: Int
    let sortBy: CatalogCollectionsSort?

    init(page: Int, size: Int, sortBy: CatalogCollectionsSort? = nil) {
        self.page = max(0, page)
        self.size = max(1, size)
        self.sortBy = sortBy
    }

    var endpoint: URL? {
        var components = CatalogRequestFactory.collectionsComponents()
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let sortBy {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy.queryValue))
        }
        components?.queryItems = queryItems
        return components?.url
    }
}
