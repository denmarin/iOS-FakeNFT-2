//
//  GetMyProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 11.04.2026.
//

import Foundation

struct GetMyProfileRequest: NetworkRequest {

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
