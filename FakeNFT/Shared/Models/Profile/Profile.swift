import Foundation

struct Profile: Sendable, Hashable, Codable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: String?
    let nfts: [String]
    let likes: [String]
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            website = try container.decodeIfPresent(String.self, forKey: .website)
            nfts = try container.decode([String].self, forKey: .nfts)
            likes = try container.decode([String].self, forKey: .likes)

            if let avatarString = try container.decodeIfPresent(String.self, forKey: .avatar),
               !avatarString.isEmpty {
                avatar = URL(string: avatarString)
            } else {
                avatar = nil
            }
        }
}
