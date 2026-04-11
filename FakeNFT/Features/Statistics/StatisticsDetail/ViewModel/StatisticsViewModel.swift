//
//  StatisticsViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//

import Foundation
import Combine

@MainActor
protocol StatisticsViewModelProtocol {
    var state: State { get }
    var users: [UserListResponse] { get }
    
    func loadUsers() async
    func refreshUsers() async
    func sortUsers(by type: SortType)
}

enum State {
    case loading
    case content
    case error(String)
    case empty
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    
    @Published private(set) var state: State = .loading
    
    @Published private(set) var users: [UserListResponse] = []
    
    private(set) var currentSortType: SortType = .byRating
    
    private let service: StatisticsServiceProtocol
    
    init(service: StatisticsServiceProtocol) {
        self.service = service
    }
    
    func loadUsers() async {
        state = .loading
        
        do {
            let loadedUsers = try await service.loadUsers()
            print("✅ Успешно распарсили \(loadedUsers.count) пользователей")
            
            self.users = loadedUsers
            sortUsers(by: .byRating
            )
            self.state = self.users.isEmpty ? .empty : .content
        } catch {
            print("❌ Ошибка сети или парсинга: \(error)")
            self.state = .error("Ошибка загрузки")
        }
    }
    
    func refreshUsers() async {
        await loadUsers()
    }
    
    func sortUsers(by type: SortType) {
        guard self.currentSortType != type else { return } 
        self.currentSortType = type
        applySorting()
    }
    
    private func applySorting() {
        switch currentSortType {
        case .byRating:
            self.users = self.users.sorted { user1, user2 in
                let rating1 = Int(user1.rating) ?? 0
                let rating2 = Int(user2.rating) ?? 0

                return rating1 > rating2
            }
            
        case .byName:
            self.users = self.users.sorted { user1, user2 in
                return (user1.name).localizedCaseInsensitiveCompare(user2.name) == .orderedAscending
            }
        }
    }
}
