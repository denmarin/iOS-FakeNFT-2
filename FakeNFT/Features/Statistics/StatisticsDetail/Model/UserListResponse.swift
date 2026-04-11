//
//  StatisticUser.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//
import Foundation

// Эта модель описывает ТОЛЬКО ответ от GET /api/v1/users
struct UserListResponse: Decodable {
    let id: String
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    
    // Сервер присылает рейтинг СТРОКОЙ ("1", "10")
    let rating: String?
    
    // Поля 'likes' в этом ответе нет, поэтому мы его просто не объявляем здесь.
    
    // Метод конвертации в нашу общую модель Profile
    func toProfile() -> Profile {
        return Profile(
            id: self.id,
            name: self.name,
            avatar: URL(string: self.avatar ?? ""),
            description: self.description,
            website: URL(string: self.website ?? ""),
            nfts: self.nfts ?? [],
            likes: [] // Лайков в списке нет, передаем пустой массив
        )
    }
}
