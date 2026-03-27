import Foundation

struct Profile: Sendable, Hashable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: URL?
    let nftIDs: [String]
    let likedNftIDs: [String]
}
