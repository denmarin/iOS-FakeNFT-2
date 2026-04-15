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
        let request: NetworkRequest
        
        if id == RequestConstants.token {
            request = GetMyProfileRequest()
        } else {
            request = ProfileRequest(userID: id)
        }
        
        let response: ProfileResponse = try await networkClient.send(request: request, type: ProfileResponse.self)
        return response.toProfile()
    }
}
