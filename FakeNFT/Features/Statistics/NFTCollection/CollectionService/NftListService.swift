//
//  CollectionService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//

import Foundation

protocol NftListServiceProtocol {
    func loadNftList(page: Int, size: Int) async throws -> [Nft]
}

final class NftListService: NftListServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadNftList(page: Int, size: Int) async throws -> [Nft] {
        let request = NftListRequest(page: page, size: size)
        
        return try await networkClient.send(request: request, type: [Nft].self)
    }
    
    
}
