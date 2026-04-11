import Foundation

struct ProfileResponse: Decodable {
    let id: String
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    let likes: [String]?
    
    func toProfile() -> Profile {
        return Profile(
            id: id,
            name: name,
            avatar: URL(string: avatar ?? ""),
            description: description,
            website: URL(string: website ?? ""),
            nfts: nfts ?? [],
            likes: likes ?? []
        )
    }
}
