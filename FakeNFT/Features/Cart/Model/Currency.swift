import Foundation

struct Currency: Codable {
    let title: String
    let name: String
    let image: String
    let id: String
}

extension Currency {
    var shortName: String {
        switch name.uppercased() {
        case "BITCOIN": return "BTC"
        case "ETHEREUM": return "ETH"
        case "DOGECOIN": return "DOGE"
        default: return name
        }
    }
}
