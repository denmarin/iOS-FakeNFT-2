import Foundation

enum CatalogRemoteURL {
    static func make(from source: String) -> URL? {
        guard
            let url = URL(string: source),
            let scheme = url.scheme?.lowercased(),
            scheme == "http" || scheme == "https"
        else {
            return nil
        }
        return url
    }
}
