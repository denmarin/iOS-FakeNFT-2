import Foundation

struct Profile: Sendable, Hashable, Codable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: URL?
    let nfts: [String]
    let likes: [String]
}
