//
//  StatisticsNftService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//
import Foundation

protocol StatisticsNftServiceProtocol {
    func loadNft(id: String) async throws -> Nft
    func loadNfts(ids: [String]) async throws -> [Nft]
}

final class StatisticsNftService: StatisticsNftServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func loadNft(id: String) async throws -> Nft {
        let request = StatisticsNftRequest(id: id)
        return try await networkClient.send(request: request, type: Nft.self)
    }
    
    func loadNfts(ids: [String]) async throws -> [Nft] {
        try await withThrowingTaskGroup(of: Nft.self) { group in
            for id in ids {
                group.addTask {
                    let request = StatisticsNftRequest(id: id)
                    return try await self.networkClient.send(request: request, type: Nft.self)
                }
            }
            
            var nfts: [Nft] = []
            for try await nft in group {
                nfts.append(nft)
            }
            return nfts
        }
    }
}

private struct StatisticsNftRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
}

final class MockStatisticsNftService: StatisticsNftServiceProtocol {
    func loadNft(id: String) async throws -> Nft {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Nft(
            id: id,
            images: [URL(string: "https://placehold.co/100")!],
            name: "NFT \(id)",
            price: 1.0,
            rating: 5,
            author: "Author",
            description: "Desc",
            website: URL(string: "https://example.com")!
        )
    }
    
    func loadNfts(ids: [String]) async throws -> [Nft] {
        var result: [Nft] = []
        for id in ids {
            result.append(try await loadNft(id: id))
        }
        return result
    }
}
