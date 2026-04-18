import Foundation

struct CatalogUserActionsState: Sendable {
    let likedNftIDs: Set<String>
    let cartNftIDs: Set<String>
}

protocol CatalogUserActionsProviding {
    func fetchUserActionsState() async throws -> CatalogUserActionsState
    func updateLikedNftIDs(_ ids: [String]) async throws -> Set<String>
    func updateCartNftIDs(_ ids: [String]) async throws -> Set<String>
}
