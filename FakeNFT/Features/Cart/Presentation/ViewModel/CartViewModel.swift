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
        nfts = [
            Nft(
                id: "1",
                images: [URL(string: "local://April")!],
                name: "April",
                price: 1.78,
                rating: 1,
                authorId: "1",
                description: "",
                website: URL(string: "https://yandex.ru")!
            ),
            Nft(
                id: "2",
                images: [URL(string: "local://Greena")!],
                name: "Greena",
                price: 1.78,
                rating: 3,
                authorId: "2",
                description: "",
                website: URL(string: "https://yandex.ru")!
            ),
            Nft(
                id: "3",
                images: [URL(string: "local://Spring")!],
                name: "Spring",
                price: 1.78,
                rating: 5,
                authorId: "3",
                description: "",
                website: URL(string: "https://yandex.ru")!
            )
        ]
        
        onChange?()
    }
}
