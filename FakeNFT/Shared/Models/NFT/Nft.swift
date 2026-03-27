import Foundation

struct Nft: Decodable {
    let id: String
    let images: [URL]
    let name: String
    let price: Double
    let rating: Int
    let authorId: String
    let description: String
    let website: URL
}
