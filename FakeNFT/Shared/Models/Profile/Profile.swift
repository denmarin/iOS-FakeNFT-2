import Foundation

struct Profile: Sendable, Hashable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: String?
    let nfts: [String]
    let likes: [String]
}
