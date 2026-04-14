//
//  UpdateOrderDto.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import Foundation

struct UpdateOrderDto: Dto {
    let nfts: [String]
    
    func asDictionary() -> [String: String] {
        return ["nfts": nfts.joined(separator: ",")]
    }
} 
