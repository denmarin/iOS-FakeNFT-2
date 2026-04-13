//
//  CartService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import Foundation

protocol CartServiceProtocol {
    func getCart() async throws -> OrderResponse
    func updateCart(nftIds: [String]) async throws -> OrderResponse
}

final class CartService: CartServiceProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getCart() async throws -> OrderResponse {
        let request = GetOrderRequest()
        return try await networkClient.send(request: request, type: OrderResponse.self)
    }
    
    func updateCart(nftIds: [String]) async throws -> OrderResponse {
        let dto = UpdateOrderDto(nfts: nftIds)
        let request = UpdateOrderRequest(dto: dto)
        return try await networkClient.send(request: request, type: OrderResponse.self)
    }
}
