//
//  NtfListRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//
import Foundation

struct NftListRequest: NetworkRequest {
    let page: Int
    let size: Int
    
    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/nft")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        return components?.url
    }
    
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

