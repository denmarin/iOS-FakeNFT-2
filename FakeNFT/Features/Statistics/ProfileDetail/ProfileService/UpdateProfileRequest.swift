//
//  UpdateProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 10.04.2026.
//

import Foundation

struct UpdateProfileRequest: NetworkRequest {
    let profileId: String
    var dto: Dto?
    
    var endpoint: URL? {
        // Документация говорит: /api/v1/profile/1 (где 1 - это ID)
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }
    
    var httpMethod: HttpMethod { .put }
    
    init(profileId: String, dto: UpdateProfileDto) {
        self.profileId = profileId
        self.dto = dto
    }
}
