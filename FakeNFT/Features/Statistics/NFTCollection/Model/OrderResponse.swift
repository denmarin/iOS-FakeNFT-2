//
//  OrderResponse.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import Foundation

struct OrderResponse: Decodable {
    let id: String
    let nfts: [String]
}
