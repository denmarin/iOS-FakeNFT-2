//
//  NtfListRequest.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 09.04.2026.
//
import Foundation

struct NtfListRequest: NetworkRequest {
    let page: Int
    let size: Int
    let sortBy: String?
    
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        if let sort = sortBy {
            components?.queryItems?.append(URLQueryItem(name: "sortBy", value: sort))
        }
        return components?.url
    }
    
    var httpMethod: HttpMethod { .get }
}
