import Foundation

protocol CartService {
    func loadCart() async throws -> [Nft]
    func updateCart(with nftIds: [String]) async throws -> Order
}

final class CartServiceImpl: CartService {
    // MARK: - Private Properties
    private let networkClient: NetworkClient
    
    // MARK: - Init
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func loadCart() async throws -> [Nft] {
        let order = try await networkClient.send(request: OrderRequest(), type: Order.self)
        
        guard !order.nfts.isEmpty else {
            return []
        }
        
        return try await withThrowingTaskGroup(of: Nft.self) { group in
            for id in order.nfts {
                group.addTask {
                    return try await self.networkClient.send(request: NFTRequest(id: id), type: Nft.self)
                }
            }
            
            var fetchedNfts: [Nft] = []
            for try await nft in group {
                fetchedNfts.append(nft)
            }
            
            return fetchedNfts.sorted { $0.id < $1.id }
        }
    }
    
    func updateCart(with nftIds: [String]) async throws -> Order {
        let request = OrderUpdateRequest(nfts: nftIds)
        return try await networkClient.send(request: request, type: Order.self)
    }
}
