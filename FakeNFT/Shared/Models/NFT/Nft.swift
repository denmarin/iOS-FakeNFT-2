import Foundation

struct Nft: Decodable, Sendable {
    let id: String
    let images: [URL]
    let name: String
    let price: Double
    let rating: Int
    let author: String
    let description: String
    let website: URL
}
