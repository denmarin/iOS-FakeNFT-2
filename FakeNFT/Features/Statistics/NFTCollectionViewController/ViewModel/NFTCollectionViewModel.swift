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
    var state: NftDetailState { get }
    
    var nfts: [Nft] { get }
    
    func loadNfts() async
}


@MainActor
final class NFTCollectionViewModel: NftCollectionViewModelProtocol {
    
    @Published private(set) var state: NftDetailState = .loading
    
    @Published private(set) var nfts: [Nft] = []
    
    private let nftIDs: [String]
    
    private let nftService: NftService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(nftIDs: [String], nftService: NftService) {
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
            var loadedNfts: [Nft] = []
            
            for id in nftIDs {
                let mockNft = createMockNft(id: id)
                loadedNfts.append(mockNft)
            }
            self.nfts = loadedNfts
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
