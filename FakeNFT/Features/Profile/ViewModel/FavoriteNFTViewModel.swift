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
    
    private var allNfts: [NftCard] = []
    private let onDelete: ([NftCard]) -> Void
    
    init(nfts: [NftCard], onDelete: @escaping ([NftCard]) -> Void) {
        self.allNfts = nfts
        self.onDelete = onDelete
        loadData()
    }
    
    func loadData() {
        state = .loading
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            updateState()
        }
    }
    
    func didTapLikeButton(nftId: String){
        allNfts.removeAll(where:{ $0.id == nftId } )
        onDelete(allNfts)
        updateState()
    }
    
    private func updateState() {
        if allNfts.isEmpty {
            state = .empty
        } else {
            state = .content(allNfts)
        }
    }
}
