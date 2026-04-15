//
//  StatisticsAssembly.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 13.04.2026.
//

import Foundation

@MainActor
final class StatisticsAssembly {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Factory Methods

    func makeProfileDetailViewModel(profile: Profile, currentUserId: String) -> ProfileDetailViewModelProtocol {
        let profileUpdateService = ProfileServiceUpdate(networkClient: networkClient)
        return ProfileDetailViewModel(
            profile: profile,
            service: profileUpdateService,
            currentUserId: currentUserId
        )
    }

    func makeNftCollectionViewController(ownerProfile: Profile) -> NftCollectionViewController {
        let nftListService = NftListService(networkClient: networkClient)
        let profileUpdateService = ProfileServiceUpdate(networkClient: networkClient)
        let myProfileService = ProfileService(networkClient: networkClient)
        
        let viewModel = NftCollectionViewModel(
            ownerProfile: ownerProfile,
            nftListService: nftListService,
            profileUpdateService: profileUpdateService,
            cartService: CartNftService(),
            myProfileService: myProfileService
        )
        
        return NftCollectionViewController(viewModel: viewModel)
    }

    func makeWebViewController(url: URL) -> WebStatisticViewController {
        let viewModel = WebStatisticViewModel(url: url)
        return WebStatisticViewController(viewModel: viewModel)
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        let statisticsService = StatisticsService(networkClient: networkClient)
        return StatisticsViewModel(service: statisticsService)
    }
}
