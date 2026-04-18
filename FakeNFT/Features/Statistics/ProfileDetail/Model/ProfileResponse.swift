import Foundation

struct ProfileResponse: Decodable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: String?
    let nfts: [String]?
    let likes: [String]?
    
    func toProfile() -> Profile {
        
        return Profile(
            id: id,
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            nfts: nfts ?? [],
            likes: likes ?? []
        )
    }
}
