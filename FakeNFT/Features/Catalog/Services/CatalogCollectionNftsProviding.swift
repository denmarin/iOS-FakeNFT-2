import Foundation

protocol CatalogCollectionNftsProviding {
    func nftsStream(for collection: CatalogCollection) -> AsyncThrowingStream<[Nft], Error>
}

extension CatalogCollectionNftsProviding {
    func fetchNfts(for collection: CatalogCollection) async throws -> [Nft] {
        var latest: [Nft] = []
        for try await partialNfts in nftsStream(for: collection) {
            latest = partialNfts
        }
        return latest
    }
}
