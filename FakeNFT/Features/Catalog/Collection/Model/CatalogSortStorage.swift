import Foundation

protocol CatalogSortStorageProtocol: AnyObject {
    var sortOption: CatalogSortOption { get set }
}

final class CatalogSortStorage: CatalogSortStorageProtocol {
    private let userDefaults: UserDefaults
    private let sortKey = "CatalogSortOptionKey"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var sortOption: CatalogSortOption {
        get {
            guard
                let rawValue = userDefaults.string(forKey: sortKey),
                let sortOption = CatalogSortOption(rawValue: rawValue)
            else {
                return .byNftCount
            }
            return sortOption
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortKey)
        }
    }
}
