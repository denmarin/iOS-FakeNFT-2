//
//  ProfileServiceUpdate.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 10.04.2026.
//

import Foundation

protocol ProfileServiceUpdateProtocol {
    func updateProfile(_ profile: UpdateProfileDto, id: String) async throws -> Profile
}

final class ProfileServiceUpdate: ProfileServiceUpdateProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func updateProfile(_ profile: UpdateProfileDto, id: String) async throws -> Profile {
        let request = UpdateProfileRequest(dto: profile)
 
        return try await networkClient.send(request: request, type: Profile.self)
    }
}
