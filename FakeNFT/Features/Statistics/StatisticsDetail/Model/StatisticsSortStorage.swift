import Foundation

protocol StatisticsSortStorageProtocol: AnyObject {
    var sortType: SortType { get set }
}

final class StatisticsSortStorage: StatisticsSortStorageProtocol {
    private let userDefaults: UserDefaults
    private let sortKey = "StatisticsSortTypeKey"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var sortType: SortType {
        get {
            guard
                let rawValue = userDefaults.string(forKey: sortKey),
                let sortType = SortType(rawValue: rawValue)
            else {
                return .byRating
            }
            return sortType
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortKey)
        }
    }
}
