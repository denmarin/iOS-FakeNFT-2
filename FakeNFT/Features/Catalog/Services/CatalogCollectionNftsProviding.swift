import Foundation

protocol CatalogCollectionNftsProviding: Sendable {
    func fetchNfts(for collection: CatalogCollection) async throws -> [Nft]
}
