//
//  StatisticUser.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//
import Foundation

struct UserListResponse: Decodable {
    let id: String
    let name: String
    let avatar: URL?
    let description: String?
    let website: String?
    let nfts: [String]?

    let rating: String
 
    func toProfile() -> Profile {

        return Profile(
            id: id,
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            nfts: nfts ?? [],
            likes: []
        )
    }
}
