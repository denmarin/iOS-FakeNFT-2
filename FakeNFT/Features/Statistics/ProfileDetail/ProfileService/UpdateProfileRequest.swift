//
//  UpdateProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 10.04.2026.
//

import Foundation

struct UpdateProfileRequest: NetworkRequest {
    var dto: Dto?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var httpMethod: HttpMethod { .put }
    
    init(dto: UpdateProfileDto) {
        self.dto = dto
    }
}
