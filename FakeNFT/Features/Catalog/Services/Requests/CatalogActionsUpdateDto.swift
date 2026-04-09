import Foundation

enum CatalogActionsField: String {
    case likes
    case nfts
}

struct CatalogActionsUpdateDTO: Dto {
    let field: CatalogActionsField
    let ids: [String]

    func asDictionary() -> [String: String] {
        let value = ids.isEmpty ? "null" : ids.joined(separator: ",")
        return [field.rawValue: value]
    }
}
