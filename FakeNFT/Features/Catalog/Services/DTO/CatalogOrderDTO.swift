import Foundation

struct CatalogOrderDTO: Decodable {
    let nftIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case nftIDs = "nfts"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nftIDs = try container.decodeIfPresent([String].self, forKey: .nftIDs) ?? []
    }
}
