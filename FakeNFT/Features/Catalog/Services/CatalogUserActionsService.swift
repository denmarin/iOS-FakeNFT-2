import Foundation

struct CatalogUserActionsService: CatalogUserActionsProviding {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchUserActionsState() async throws -> CatalogUserActionsState {
        async let profile = networkClient.send(
            request: CatalogProfileRequest(),
            type: CatalogProfileActionsDTO.self
        )
        async let order = networkClient.send(
            request: CatalogOrderRequest(),
            type: CatalogOrderDTO.self
        )

        let (profileDTO, orderDTO) = try await (profile, order)
        return CatalogUserActionsState(
            likedNftIDs: Set(profileDTO.likedNftIDs),
            cartNftIDs: Set(orderDTO.nftIDs)
        )
    }

    func updateLikedNftIDs(_ ids: [String]) async throws -> Set<String> {
        let request = CatalogUpdateProfileLikesRequest(ids: ids)
        let response = try await networkClient.send(
            request: request,
            type: CatalogProfileActionsDTO.self
        )
        return Set(response.likedNftIDs)
    }

    func updateCartNftIDs(_ ids: [String]) async throws -> Set<String> {
        let request = CatalogUpdateOrderNftsRequest(ids: ids)
        let response = try await networkClient.send(
            request: request,
            type: CatalogOrderDTO.self
        )
        return Set(response.nftIDs)
    }
}
