//
//  StatisticsService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 03.04.2026.
//

import Foundation

// MARK: - Протокол сервиса
protocol StatisticsServiceProtocol {
    func loadUsers() async throws -> [UserListResponse]
}

// MARK: - Реализация сервиса
final class StatisticsService: StatisticsServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadUsers() async throws -> [UserListResponse] {
        let request = StatisticsUsersRequest()
        
        let response: [UserListResponse] = try await networkClient.send(
            request: request,
            type: [UserListResponse].self
        )
        
        let sortedResponse = response.sorted {
            (Int($0.rating) ?? 0) > (Int($1.rating) ?? 0)
        }
        
        return sortedResponse
    }
    
}
