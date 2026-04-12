import Foundation

protocol CartSortStorageProtocol: AnyObject {
    var sortType: CartSortType { get set }
}

final class CartSortStorage: CartSortStorageProtocol {
    private let userDefaults = UserDefaults.standard
    private let sortTypeKey = "CartSortTypeKey"
    
    var sortType: CartSortType {
        get {
            guard let savedValue = userDefaults.string(forKey: sortTypeKey),
                  let type = CartSortType(rawValue: savedValue) else {
                return .name
            }
            return type
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortTypeKey)
        }
    }
}
