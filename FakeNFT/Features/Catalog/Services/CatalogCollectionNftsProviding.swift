import Foundation

protocol CatalogCollectionNftsProviding {
    func fetchNfts(
        for collection: CatalogCollection,
        onPartialResult: @MainActor @escaping @Sendable ([Nft]) -> Void
    ) async throws -> [Nft]
}

extension CatalogCollectionNftsProviding {
    func fetchNfts(for collection: CatalogCollection) async throws -> [Nft] {
        try await fetchNfts(for: collection) { _ in }
    }
}
