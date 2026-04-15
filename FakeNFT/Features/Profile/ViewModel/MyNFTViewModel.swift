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
    
    private var myNftsId: [String]
    private var myNfts: [NftCard]
    private let provider: ProfileDataProvider
    
    private let storageKey = "MyNftSortTypeKey"
    
    private var currentSort: MyNftSortType {
        get {
            guard UserDefaults.standard.object(forKey: storageKey) != nil else {
                return .rating
            }
            let savedValue = UserDefaults.standard.integer(forKey: storageKey)
            return MyNftSortType(rawValue: savedValue) ?? .rating
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }
    
    init(nfts: [NftCard],nftsIds: [String], provider: ProfileDataProvider) {
        self.myNfts = nfts
        self.myNftsId = nftsIds
        self.provider = provider
    }
    
    func loadData() async {
        myNfts = myNfts.filter { myNftsId.contains($0.id) }
        
        let loadedIds = myNfts.map { $0.id }
        let idsToFetch = myNftsId.filter { !loadedIds.contains($0) }
        
        guard !idsToFetch.isEmpty else {
            if myNfts.isEmpty {
                state = .empty
            } else {
                applySort()
            }
            return
        }
        
        state = .loading
        
        do {
            let newNfts = try await provider.loadNFTs(ids: idsToFetch)
            
            self.myNfts += newNfts
            
            if myNfts.isEmpty {
                state = .empty
            } else {
                applySort()
            }
        } catch {
            state = .error(String(localized: "Error.unknown"))
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
            sortedNfts = myNfts.sorted { $0.price > $1.price }
        case .rating:
            sortedNfts = myNfts.sorted { $0.rating > $1.rating }
        case .name:
            sortedNfts = myNfts.sorted { $0.title < $1.title }
        }
        state = .content(sortedNfts)
    }
}
