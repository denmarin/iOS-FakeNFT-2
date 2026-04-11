//
//  StatisticsNftService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 03.04.2026.
//

import Foundation

// MARK: - Протокол сервиса
protocol StatisticsServiceProtocol {
    func loadUsers() async throws -> [Profile]
}

// MARK: - Реализация сервиса
final class StatisticsService: StatisticsServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadUsers() async throws -> [Profile] {
        let request = UsersRequest()
        
        let profiles: [Profile] = try await networkClient.send(
            request: request,
            type: [Profile].self
        )
    }
}

// MARK: - Mock-реализация для разработки (пока нет API)
final class MockStatisticsNftService: StatisticsServiceProtocol {
    func loadUsers() async throws -> [Profile] {
        <#code#>
    }
    
    
    private let mockImageURLs = [
        "https://placehold.co/108x108/FF5733/white?text=NFT1",
        "https://placehold.co/108x108/33FF57/white?text=NFT2",
        "https://placehold.co/108x108/3357FF/white?text=NFT3",
        "https://placehold.co/108x108/F333FF/white?text=NFT4",
        "https://placehold.co/108x108/FF33F5/white?text=NFT5"
    ]
    
    private let mockNames = [
        "Косм",
        "Драк",
        "Кибер",
        "Подвод",
        "Маг"
    ]
    
    func loadNft(id: String) async throws -> Nft {
        let delay = Double.random(in: 0.3...0.8)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return createMockNft(id: id)
    }
    
    func loadNfts(ids: [String]) async throws -> [Nft] {
        try await withThrowingTaskGroup(of: Nft.self, returning: [Nft].self) { group in
            for id in ids {
                group.addTask {
                    return try await self.loadNft(id: id)
                }
            }
            
            var nfts: [Nft] = []
            for try await nft in group {
                nfts.append(nft)
            }
            return nfts
        }
    }
    
    private func createMockNft(id: String) -> Nft {
        let imageIndex = abs(id.hashValue) % mockImageURLs.count
        let imageURL = URL(string: mockImageURLs[imageIndex])!
        
        let nameIndex = abs(id.hashValue) % mockNames.count
        let name = mockNames[nameIndex]
        
        return Nft(
            id: id,
            images: [imageURL],
            name: name,
            price: Double(Int.random(in: 5...150)),
            rating: Int.random(in: 1...5),
            author: "author_\(id)",
            description: "Удивительное произведение цифрового искусства.",
            website: URL(string: "https://example.com/nft/\(id)")!
        )
    }
}
