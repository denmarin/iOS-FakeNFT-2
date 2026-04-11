//
//  MyProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 11.04.2026.
//

//
//  ProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//

import Foundation

struct MyProfileRequest: NetworkRequest {
    let userID: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var httpMethod: HttpMethod { .get }
}
