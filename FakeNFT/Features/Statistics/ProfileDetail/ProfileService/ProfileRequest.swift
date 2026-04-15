//
//  ProfileRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//

import Foundation

struct ProfileRequest: NetworkRequest {
    let userID: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(userID)")
    }
    
    var httpMethod: HttpMethod { .get }
}
