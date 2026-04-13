import Foundation
import Combine

enum FavoriteNftViewState {
    case loading
    case content([NftCard])
    case empty
    case error(String)
}

@MainActor
final class FavoriteNFTViewModel: ObservableObject {
    @Published private(set) var state: FavoriteNftViewState = .loading
    
    private var favoriteNftsIds: [String]
    private var favoriteNfts: [NftCard]
    private let onDelete: ([NftCard], [String]) -> Void
    private let header: ProfileHeader
    private let provider: ProfileDataProvider
    
    init(nftsIds: [String],nftCards: [NftCard],dataProvider: ProfileDataProvider,header: ProfileHeader, onDelete: @escaping ([NftCard], [String]) -> Void) {
        self.favoriteNftsIds = nftsIds
        self.favoriteNfts = nftCards
        self.provider = dataProvider
        self.header = header
        self.onDelete = onDelete
    }
    
    func loadData() async {
        
        favoriteNfts = favoriteNfts.filter { favoriteNftsIds.contains($0.id) }
        
        let loadedIds = favoriteNfts.map { $0.id }
        let idsToFetch = favoriteNftsIds.filter { !loadedIds.contains($0) }
        
        guard !idsToFetch.isEmpty else {
            updateState()
            return
        }
        
        state = .loading
        do {
            
            let newNfts = try await provider.loadNFTs(ids: idsToFetch)
            
            let updatedList = favoriteNfts + newNfts
            
            self.favoriteNfts = updatedList
            self.updateState()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func didTapLikeButton(nftId: String) {
        let updatedLikesIds = favoriteNftsIds.filter { $0 != nftId }
        print(updatedLikesIds)
        state = .loading
        
        Task {
            do {
                let _ = try await provider.updateProfile(
                    name: header.name,
                    description: header.description,
                    website: header.website ?? "",
                    avatar: header.avatar?.absoluteString ?? "",
                    likes: updatedLikesIds
                )
                
                self.favoriteNfts.removeAll(where: { $0.id == nftId })
                self.favoriteNftsIds = updatedLikesIds
                
                onDelete(favoriteNfts, favoriteNftsIds)
                
                updateState()
            } catch {
                state = .error("Не удалось удалить лайк: \(error.localizedDescription)")
                updateState()
            }
        }
    }
    
    
    private func updateState() {
        if favoriteNfts.isEmpty {
            state = .empty
        } else {
            state = .content(favoriteNfts)
        }
    }
}
