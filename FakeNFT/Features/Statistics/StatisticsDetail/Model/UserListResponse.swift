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
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?

    let rating: String
 
    func toProfile() -> Profile {
        return Profile(
            id: self.id,
            name: self.name,
            avatar: URL(string: self.avatar ?? ""),
            description: self.description,
            website: URL(string: self.website ?? ""),
            nfts: self.nfts ?? [],
            likes: []
        )
    }
}
