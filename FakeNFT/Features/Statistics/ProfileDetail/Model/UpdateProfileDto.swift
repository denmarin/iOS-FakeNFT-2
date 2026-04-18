//
//  UpdateProfileDto.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 10.04.2026.
//

import Foundation

struct UpdateProfileDto: Dto {
    let name: String
    let description: String
    let avatar: String
    let website: String
    let likes: [String]
    
    func asDictionary() -> [String: String] {
        return [
            "name": name,
            "description": description,
            "avatar": avatar,
            "website": website,
            "likes": likes.joined(separator: ",")
        ]
    }
}
