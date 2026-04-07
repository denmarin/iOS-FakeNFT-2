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
    var users: [StatisticUser] { get }
    
    func loadUsers() async
    func refreshUsers() async
}

enum State {
    case loading
    case content
    case error(String)
    case empty
}

enum SortType {
    case byRating
    case byName
}

final class StatisticsViewModel: StatisticsViewModelProtocol {

    @Published private(set) var state: State = .loading
    
    @Published private(set) var users: [StatisticUser] = []
    
    private(set) var currentSortType: SortType = .byRating
    
    func loadUsers() async {
        state = .loading
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let mockUsers = [
                    StatisticUser(
                        id: "1",
                        name: "Alex",
                        rating: 1,
                        score: 112,
                        avatarUrl: URL(string: "https://example.com/alex.jpg")
                    ),
                    StatisticUser(
                        id: "2",
                        name: "Bill",
                        rating: 2,
                        score: 98,
                        avatarUrl: URL(string: "https://example.com/bill.jpg")
                    ),
                    StatisticUser(
                        id: "3",
                        name: "Alla",
                        rating: 3,
                        score: 72,
                        avatarUrl: URL(string: "https://example.com/alla.jpg")
                    ),
                    StatisticUser(
                        id: "4",
                        name: "Mads",
                        rating: 4,
                        score: 71,
                        avatarUrl: URL(string: "https://example.com/mads.jpg")
                    ),
                    StatisticUser(
                        id: "5",
                        name: "Timothée",
                        rating: 5,
                        score: 51,
                        avatarUrl: URL(string: "https://example.com/timothee.jpg")
                    ),
                    StatisticUser(
                        id: "6",
                        name: "Lea",
                        rating: 6,
                        score: 23,
                        avatarUrl: URL(string: "https://example.com/lea.jpg")
                    ),
                    StatisticUser(
                        id: "7",
                        name: "Eric",
                        rating: 7,
                        score: 11,
                        avatarUrl: URL(string: "https://example.com/eric.jpg")
                    )
                ]
        
        self.users = mockUsers
        
        self.state = .content
    }
    
    func refreshUsers() async {
        await loadUsers()
    }
    
    func sotrUser(by type: SortType) {
        // реализация следующем спринте.
    }
}
