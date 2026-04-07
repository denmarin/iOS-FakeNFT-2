//
//  StatisticsNftService.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 03.04.2026.
//

import Foundation

// MARK: - Протокол сервиса
// Определяет, что умеет делать сервис
protocol StatisticsNftServiceProtocol {
    /// Загружает один NFT по ID
    /// - Parameter id: ID NFT
    /// - Returns: Nft
    /// - Throws: Ошибку, если загрузка не удалась
    func loadNft(id: String) async throws -> Nft
    
    /// Загружает несколько NFT по массиву ID
    /// - Parameter ids: массив ID NFT
    /// - Returns: массив Nft
    /// - Throws: Ошибку, если загрузка не удалась
    func loadNfts(ids: [String]) async throws -> [Nft]
}

// MARK: - Реализация сервиса
final class StatisticsNftService: StatisticsNftServiceProtocol {
    
    // MARK: - Private Properties
    private let baseURL = "https://your-api.com/nft/"  // TODO: заменить на реальный URL
    private let session = URLSession.shared
    
    // MARK: - Public Methods
    
    /// Загружает один NFT по ID
    func loadNft(id: String) async throws -> Nft {
        // 1. Создаём URL для запроса
        guard let url = URL(string: "\(baseURL)\(id)") else {
            throw NSError(domain: "StatisticsNftService", code: 400,
                         userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])
        }
        
        // 2. Создаём запрос
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Выполняем запрос
        let (data, response) = try await session.data(for: request)
        
        // 4. Проверяем статус ответа
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "StatisticsNftService", code: 500,
                         userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])
        }
        
        // 5. Декодируем данные в модель Nft
        let decoder = JSONDecoder()
        let nft = try decoder.decode(Nft.self, from: data)
        
        return nft
    }
    
    /// Загружает несколько NFT по массиву ID (параллельно)
    func loadNfts(ids: [String]) async throws -> [Nft] {
        // Используем TaskGroup для параллельной загрузки
        try await withThrowingTaskGroup(of: Nft.self, returning: [Nft].self) { group in
            // Добавляем задачи для каждого ID
            for id in ids {
                group.addTask {
                    return try await self.loadNft(id: id)
                }
            }
            
            // Собираем результаты
            var nfts: [Nft] = []
            for try await nft in group {
                nfts.append(nft)
            }
            return nfts
        }
    }
}

// MARK: - Mock-реализация для разработки (пока нет API)
final class MockStatisticsNftService: StatisticsNftServiceProtocol {
    
    private let mockImageURLs = [
        "https://placehold.co/108x108/FF5733/white?text=NFT1",
        "https://placehold.co/108x108/33FF57/white?text=NFT2",
        "https://placehold.co/108x108/3357FF/white?text=NFT3",
        "https://placehold.co/108x108/F333FF/white?text=NFT4",
        "https://placehold.co/108x108/FF33F5/white?text=NFT5"
    ]
    
    private let mockNames = [
        "Косм",
        "Драк",
        "Кибер",
        "Подвод",
        "Маг"
    ]
    
    func loadNft(id: String) async throws -> Nft {
        let delay = Double.random(in: 0.3...0.8)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return createMockNft(id: id)
    }
    
    func loadNfts(ids: [String]) async throws -> [Nft] {
        try await withThrowingTaskGroup(of: Nft.self, returning: [Nft].self) { group in
            for id in ids {
                group.addTask {
                    return try await self.loadNft(id: id)
                }
            }
            
            var nfts: [Nft] = []
            for try await nft in group {
                nfts.append(nft)
            }
            return nfts
        }
    }
    
    private func createMockNft(id: String) -> Nft {
        let imageIndex = abs(id.hashValue) % mockImageURLs.count
        let imageURL = URL(string: mockImageURLs[imageIndex])!
        
        let nameIndex = abs(id.hashValue) % mockNames.count
        let name = mockNames[nameIndex]
        
        return Nft(
            id: id,
            images: [imageURL],
            name: name,
            price: Double(Int.random(in: 5...150)),
            rating: Int.random(in: 1...5),
            authorId: "author_\(id)",
            description: "Удивительное произведение цифрового искусства.",
            website: URL(string: "https://example.com/nft/\(id)")!
        )
    }
}
