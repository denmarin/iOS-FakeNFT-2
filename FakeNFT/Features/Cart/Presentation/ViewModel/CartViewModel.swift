import Foundation

final class CartViewModel {
    // MARK: - Public Properties
    var onChange: (() -> Void)?
    
    var items: [Nft] {
        nfts
    }
    
    var totalPrice: Double {
        nfts.reduce(0) { $0 + $1.price }
    }
    
    var totalAmount: Int {
        nfts.count
    }
    
    // MARK: - Private Properties
    private var nfts: [Nft] = []
    
    // MARK: - Public Methods
    func loadData() {
        self.nfts = MockData.nfts
        onChange?()
    }
}
