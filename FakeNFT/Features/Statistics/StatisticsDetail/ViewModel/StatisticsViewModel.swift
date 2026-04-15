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
    
    private(set) var currentSortType: SortType
    
    private let service: StatisticsServiceProtocol
    private let sortStorage: StatisticsSortStorageProtocol
    
    var onErrorShowAlert: (() -> Void)?
    
    init(
        service: StatisticsServiceProtocol,
        sortStorage: StatisticsSortStorageProtocol = StatisticsSortStorage()
    ) {
        self.service = service
        self.sortStorage = sortStorage
        self.currentSortType = sortStorage.sortType
    }
    
    func loadUsers() async {
        state = .loading
        
        do {
            let loadedUsers = try await service.loadUsers()
            self.users = loadedUsers
            applySorting()
            self.state = self.users.isEmpty ? .empty : .content
        } catch {
            self.state = .error("Ошибка загрузки")
            onErrorShowAlert?()
        }
    }
    
    func refreshUsers() async {
        await loadUsers()
    }
    
    func sortUsers(by type: SortType) {
        guard self.currentSortType != type else { return }
        self.currentSortType = type
        self.sortStorage.sortType = type
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
