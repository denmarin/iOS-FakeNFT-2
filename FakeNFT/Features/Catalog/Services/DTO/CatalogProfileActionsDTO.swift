import Foundation

struct CatalogProfileActionsDTO: Decodable {
    let likedNftIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case likedNftIDs = "likes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.likedNftIDs = try container.decodeIfPresent([String].self, forKey: .likedNftIDs) ?? []
    }
}
