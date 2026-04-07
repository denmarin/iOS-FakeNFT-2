//
//  NFTCollectionViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 01.04.2026.
//

import Foundation
import Combine

enum NftCollectionState {
    case loading
    case content
    case error(String)
    case empty
}

protocol NftCollectionViewModelProtocol {
    var state: NftCollectionState { get }
    
    var statePublisher: AnyPublisher<NftCollectionState, Never> { get }
    var nftsPublisher: AnyPublisher<[Nft], Never> { get }
    
    
    var nfts: [Nft] { get }
    func loadNfts() async
}


@MainActor
final class NftCollectionViewModel: @preconcurrency NftCollectionViewModelProtocol {
    
    var statePublisher: AnyPublisher<NftCollectionState, Never> {
        return $state.eraseToAnyPublisher()
    }
    
    var nftsPublisher: AnyPublisher<[Nft], Never> {
        return $nfts.eraseToAnyPublisher()
    }
    
    
    @Published private(set) var state: NftCollectionState = .loading
    
    @Published private(set) var nfts: [Nft] = []
    
    private let nftIDs: [String]
    
    private let nftService: StatisticsNftServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(nftIDs: [String], nftService: StatisticsNftServiceProtocol) {
        self.nftIDs = nftIDs
        self.nftService = nftService
    }
    
    func loadNfts() async {
        if nftIDs.isEmpty {
            state = .empty
            return
        }
        
        state = .loading
        
        do {
            
            let loadedNfts = try await nftService.loadNfts(ids: nftIDs)
            
            let sortedNfts = loadedNfts.sorted { $0.rating > $1.rating }
            
            self.nfts = sortedNfts
            self.state = .content
            
        } catch {
            self.state = .error(error.localizedDescription)
        }
        
    }
    
    private func createMockNft(id: String) -> Nft {
        return Nft(
            id: id,
            images: [URL(string: "https://example.com/nft.jpg")!],
            name: "NFT #\(id)",
            price: Double.random(in: 0.1...10.0),
            rating: Int.random(in: 1...5),
            authorId: "author\(id)",
            description: "Описание NFT \(id)",
            website: URL(string: "https://example.com")!
        )
    }
}
