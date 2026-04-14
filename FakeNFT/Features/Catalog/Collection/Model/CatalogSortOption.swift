import Foundation

enum CatalogSortOption: String, CaseIterable, Equatable, Sendable {
    case byName
    case byNftCount

    var displayTitle: String {
        switch self {
        case .byName:
            String(localized: "catalog.collection.sort.option.byName")
        case .byNftCount:
            String(localized: "catalog.collection.sort.option.byNftCount")
        }
    }
}
