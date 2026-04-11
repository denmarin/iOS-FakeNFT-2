//
//  ProfileService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//

import Foundation

protocol ProfileServiceProtocol {
    func loadProfile(id: String) async throws -> Profile
}

final class ProfileService: ProfileServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadProfile(id: String) async throws -> Profile {
        let request = ProfileRequest(userID: id)
        
        return try await networkClient.send(request: request, type: Profile.self)
    }
    
    
}
