import Foundation

protocol CatalogCollectionsProviding: Sendable {
    func fetchCollections() async throws -> [CatalogCollection]
}
