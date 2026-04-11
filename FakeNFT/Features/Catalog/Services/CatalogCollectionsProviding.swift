import Foundation

enum CatalogCollectionsSort: Sendable, Equatable {
    case byNameAscending
    case byNftCountDescending

    var queryValue: String {
        switch self {
        case .byNameAscending:
            "name,asc"
        case .byNftCountDescending:
            "nfts,desc"
        }
    }
}

struct CatalogCollectionsPage: Sendable, Equatable {
    let collections: [CatalogCollection]
    let hasNextPage: Bool
}

protocol CatalogCollectionsProviding {
    func fetchCollectionsPage(
        page: Int,
        sortBy: CatalogCollectionsSort?
    ) async throws -> CatalogCollectionsPage
}
