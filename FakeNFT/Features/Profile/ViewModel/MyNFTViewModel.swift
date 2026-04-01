import Foundation
import Combine

enum MyNftSortType: Int {
    case price = 0
    case rating = 1
    case name = 2
}

enum MyNftViewState {
    case loading
    case content([NftCard])
    case empty
    case error(String)
}

@MainActor
final class MyNFTViewModel: ObservableObject {
    @Published private(set) var state: MyNftViewState = .loading
    
    private var allNfts: [NftCard] = []
    
    private let storageKey = "MyNftSortTypeKey"
    
    private var currentSort: MyNftSortType {
        get {
            guard UserDefaults.standard.object(forKey: storageKey) != nil else {
                return .name
            }
            let savedValue = UserDefaults.standard.integer(forKey: storageKey)
            return MyNftSortType(rawValue: savedValue) ?? .rating
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }
    
    init(nfts: [NftCard]) {
        self.allNfts = nfts
        loadData()
    }
    
    func loadData() {
        state = .loading
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if allNfts.isEmpty {
                state = .empty
            } else {
                applySort()
            }
        }
    }
    
    func sort(by type: MyNftSortType) {
        currentSort = type
        applySort()
    }
    
    private func applySort() {
        let sortedNfts: [NftCard]
        switch currentSort {
        case .price:
            sortedNfts = allNfts.sorted { $0.priceText > $1.priceText }
        case .rating:
            sortedNfts = allNfts.sorted { $0.rating > $1.rating }
        case .name:
            sortedNfts = allNfts.sorted { $0.title < $1.title }
        }
        state = .content(sortedNfts)
    }
}
