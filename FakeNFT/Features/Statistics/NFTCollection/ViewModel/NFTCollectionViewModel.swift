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
    private let cartService: CartServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var myLikes: [String] = []
    private var currentCartIds: [String] = []
    
    init(
        ownerProfile: Profile,
        nftListService: NftListServiceProtocol,
        profileUpdateService: ProfileServiceUpdateProtocol,
        cartService: CartServiceProtocol = CartService(),
        myProfileService: ProfileServiceProtocol
    ) {
        self.ownerProfile = ownerProfile
        self.nftListService = nftListService
        self.profileUpdateService = profileUpdateService
        self.cartService = cartService
        self.myProfileService = myProfileService
    }
    
    func loadNfts() async {
        print("🚀 loadNfts: Начинаем загрузку коллекции")
        
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
            print("❌ Ошибка: Профиль еще не загружен!")
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
                website: currentProfile.website?.absoluteString ?? "",
                likes: self.myLikes
            )

            let responseProfile = try await profileUpdateService.updateProfile(dto, id: RequestConstants.token)

            self.myProfile = responseProfile
            
            print("✅ Лайк успешно обновлен на сервере")
            
        } catch {
            print("❌ Ошибка обновления: \(error)")
            if isCurrentlyLiked { myLikes.append(nftId) } else { myLikes.removeAll { $0 == nftId } }
            nfts = nfts
        }
    }
    
    func toggleCart(for nftId: String) async {
        var newCartIds = currentCartIds

        if newCartIds.contains(nftId) {
            newCartIds.removeAll { $0 == nftId }
        } else {
            newCartIds.append(nftId)
        }
        
        self.currentCartIds = newCartIds
        self.nfts = self.nfts
        
        do {
            _ = try await cartService.updateCart(nftIds: newCartIds)
            let order = try await cartService.getCart()
            self.currentCartIds = order.nfts
            
        } catch {
            print("❌ Ошибка корзины: \(error)")
            
            do {
                let order = try await cartService.getCart()
                self.currentCartIds = order.nfts
                self.nfts = self.nfts
            } catch {
                print("❌ Не удалось восстановить состояние корзины: \(error)")
            }
        }
    }
}
