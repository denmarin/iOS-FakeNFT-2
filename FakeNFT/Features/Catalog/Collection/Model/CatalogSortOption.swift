import Foundation

enum CatalogSortOption: String, CaseIterable, Equatable, Sendable {
    case byName
    case byNftCount

    var displayTitle: String {
        switch self {
        case .byName:
            return "По названию"
        case .byNftCount:
            return "По количеству NFT"
        }
    }
}
