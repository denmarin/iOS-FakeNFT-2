import Foundation

struct CatalogCollection: Equatable, Sendable {
    let id: String
    let name: String
    let coverImageName: String
    let nftIDs: [String]
    let description: String
    let authorName: String

    var nftCount: Int {
        nftIDs.count
    }
}
