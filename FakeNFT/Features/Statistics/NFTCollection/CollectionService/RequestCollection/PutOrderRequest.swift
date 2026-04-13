//
//  UpdateOrderRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import Foundation

struct UpdateOrderRequest: NetworkRequest {
    var dto: Dto?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod { .put }
    
    init(dto: UpdateOrderDto) {
        self.dto = dto
    }
}
