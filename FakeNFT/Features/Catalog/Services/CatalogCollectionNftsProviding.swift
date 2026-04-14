import Foundation

protocol CatalogCollectionNftsProviding {
    func nftsStream(for collection: CatalogCollection) -> AsyncThrowingStream<[Nft], Error>
}
