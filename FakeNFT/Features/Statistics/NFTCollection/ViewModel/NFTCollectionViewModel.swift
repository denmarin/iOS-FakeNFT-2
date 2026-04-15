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
    func toggleLike(for nftId: String) async
    
    func isLiked(nftId: String) -> Bool
    func isInCart(nftId: String) -> Bool
    func toggleCart(for nftId: String) async
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
    
    private let ownerProfile: Profile
    private var myProfile: Profile?

    
    private let nftListService: NftListServiceProtocol
    private let profileUpdateService: ProfileServiceUpdateProtocol
    private let myProfileService: ProfileServiceProtocol
    private let cartService: CartNftServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var myLikes: [String] = []
    private var currentCartIds: [String] = []
    
    init(
        ownerProfile: Profile,
        nftListService: NftListServiceProtocol,
        profileUpdateService: ProfileServiceUpdateProtocol,
        cartService: CartNftServiceProtocol = CartNftService(),
        myProfileService: ProfileServiceProtocol
    ) {
        self.ownerProfile = ownerProfile
        self.nftListService = nftListService
        self.profileUpdateService = profileUpdateService
        self.cartService = cartService
        self.myProfileService = myProfileService
    }
    
    func loadNfts() async {
        guard !ownerProfile.nfts.isEmpty else {
            state = .empty
            return
        }
        
        state = .loading
        
        do {
            
            let myProfile = try await myProfileService.loadProfile(id: RequestConstants.token)
            
            self.myProfile = myProfile
            self.myLikes = myProfile.likes
            
            let order = try await cartService.getCart()
            self.currentCartIds = order.nfts
            
            let allNfts = try await nftListService.loadNftList(page: 0, size: 100)
            
            let collection = allNfts.filter { ownerProfile.nfts.contains($0.id) }
            
            if collection.isEmpty {
                self.nfts = []
                self.state = .empty
                return
            }
            
            self.nfts = collection.sorted { $0.rating > $1.rating }
            self.state = .content
            
            
        } catch {
            self.state = .error(error.localizedDescription)
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return myLikes.contains(nftId)
    }
    
    func isInCart(nftId: String) -> Bool {
        return currentCartIds.contains(nftId)
    }
    
    func toggleLike(for nftId: String) async {
        let isCurrentlyLiked = myLikes.contains(nftId)
        if isCurrentlyLiked {
            myLikes.removeAll { $0 == nftId }
        } else {
            myLikes.append(nftId)
        }
        
        let currentNfts = nfts
        self.nfts = currentNfts
        
        guard let currentProfile = self.myProfile else {
            if isCurrentlyLiked {
                myLikes.append(nftId)
            } else {
                myLikes.removeAll { $0 == nftId }
            }
            self.nfts = currentNfts
            return
        }
        
        do {
            let dto = UpdateProfileDto(
                name: currentProfile.name,
                description: currentProfile.description ?? "",
                avatar: currentProfile.avatar?.absoluteString ?? "",
                website: currentProfile.website ?? "",
                likes: self.myLikes
            )

            let responseProfile = try await profileUpdateService.updateProfile(dto, id: RequestConstants.token)

            self.myProfile = responseProfile
        } catch {
            if isCurrentlyLiked { myLikes.append(nftId) } else { myLikes.removeAll { $0 == nftId } }
            nfts = nfts
        }
    }
    
    func toggleCart(for nftId: String) async {
        let shouldBeInCart = !currentCartIds.contains(nftId)
        var newCartIds = currentCartIds
        if shouldBeInCart {
            newCartIds.append(nftId)
        } else {
            newCartIds.removeAll { $0 == nftId }
        }
        
        self.currentCartIds = newCartIds
        self.nfts = self.nfts
        
        do {
            let remoteOrder = try await cartService.getCart()
            var mergedIds = Set(remoteOrder.nfts)
            if shouldBeInCart {
                mergedIds.insert(nftId)
            } else {
                mergedIds.remove(nftId)
            }

            _ = try await cartService.updateCart(nftIds: mergedIds.sorted())
            let order = try await cartService.getCart()
            self.currentCartIds = order.nfts
            
        } catch {
            do {
                let order = try await cartService.getCart()
                self.currentCartIds = order.nfts
                self.nfts = self.nfts
            } catch { }
        }
    }
}
