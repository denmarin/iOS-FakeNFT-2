import Foundation

enum ProfileConstants {
    static var profileUrl: URL {
        URL(string: "https://practicum.yandex.ru/ios-developer/") ?? URL(fileURLWithPath: "")
    }
}
