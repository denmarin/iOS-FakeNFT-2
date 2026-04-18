//
//  StatisticsUsersRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 08.04.2026.
//

import Foundation

struct StatisticsUsersRequest: NetworkRequest {
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users")
    }

    var httpMethod: HttpMethod {
        .get
    }
}
