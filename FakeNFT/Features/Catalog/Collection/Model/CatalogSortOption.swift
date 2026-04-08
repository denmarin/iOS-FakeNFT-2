import Foundation

enum CatalogSortOption: String, CaseIterable, Equatable, Sendable {
    case byName
    case byNftCount

    var displayTitle: String {
        switch self {
        case .byName:
            "По названию"
        case .byNftCount:
            "По количеству NFT"
        }
    }
}
