import Foundation

struct CatalogCollectionDTO: Decodable {
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}
