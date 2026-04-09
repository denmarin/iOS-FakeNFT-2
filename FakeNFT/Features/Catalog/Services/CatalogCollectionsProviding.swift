import Foundation

protocol CatalogCollectionsProviding {
    func fetchCollections(
        onPartialResult: @MainActor @escaping @Sendable ([CatalogCollection]) -> Void
    ) async throws -> [CatalogCollection]
}

extension CatalogCollectionsProviding {
    func fetchCollections() async throws -> [CatalogCollection] {
        try await fetchCollections { _ in }
    }
}
