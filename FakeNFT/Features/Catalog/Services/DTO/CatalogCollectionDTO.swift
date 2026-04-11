import Foundation

struct CatalogCollectionDTO: Decodable {
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let id: String

    private enum CodingKeys: String, CodingKey {
        case name
        case cover
        case nfts
        case description
        case author
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.cover = try container.decode(String.self, forKey: .cover)
        let rawNftIDs = try container.decode([String].self, forKey: .nfts)
        self.nfts = rawNftIDs.uniquePreservingOrder()
        self.description = try container.decode(String.self, forKey: .description)
        self.author = try container.decode(String.self, forKey: .author)
        self.id = try container.decode(String.self, forKey: .id)
    }
}

private extension Array where Element: Hashable {
    func uniquePreservingOrder() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
