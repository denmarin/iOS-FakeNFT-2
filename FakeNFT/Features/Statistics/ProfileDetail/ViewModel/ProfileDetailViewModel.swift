//
//  ProfileDetailViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 30.03.2026.
//

import Foundation

protocol ProfileDetailViewModelProtocol {
    var profile: Profile { get }
    var rating: Int? { get }
}

@MainActor
final class ProfileDetailViewModel: ProfileDetailViewModelProtocol {
    
    var rating: Int?
    
    private(set) var profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }
}
