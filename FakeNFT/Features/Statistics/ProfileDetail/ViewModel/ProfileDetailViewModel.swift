//
//  ProfileDetailViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 30.03.2026.
//

import Foundation

protocol ProfileDetailViewModelProtocol {
    var profile: Profile { get }
}

@MainActor
final class ProfileDetailViewModel: @preconcurrency ProfileDetailViewModelProtocol {
   
    @Published var profile: Profile
    private let profileService: ProfileServiceUpdateProtocol
    private let currentUserId: String
    
    init(profile: Profile,
             service: ProfileServiceUpdateProtocol = ProfileServiceUpdate(),
             currentUserId: String) { 
            self.profile = profile
            self.profileService = service
            self.currentUserId = currentUserId
        }
    
    func toggleLike(for nftId: String) async {

        let currentLikes = profile.likes
        
        var newLikes: [String]
        
        if currentLikes.contains(nftId) {
            newLikes = currentLikes.filter { $0 != nftId }
        } else {
            newLikes = currentLikes + [nftId]
        }
        let oldProfile = profile
        let updatedProfile = Profile(
            id: profile.id,
            name: profile.name,
            avatar: profile.avatar,
            description: profile.description,
            website: profile.website,
            nfts: profile.nfts,
            likes: newLikes
        )
        
        profile = updatedProfile
        
        do {
            let dto = UpdateProfileDto(
                name: profile.name,
                description: profile.description ?? "",
                avatar: profile.avatar?.absoluteString ?? "",
                website: profile.website?.absoluteString ?? "",
                likes: newLikes
            )
     
            let serverResponse = try await profileService.updateProfile(dto, id: currentUserId)

            profile = serverResponse
            print("✅ Профиль успешно обновлен")
            
        } catch {
            print("❌ Ошибка обновления профиля: \(error)")
            profile = oldProfile
        }
    }
    
}
