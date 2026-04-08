import Foundation

@MainActor
final class CartViewModel {
    // MARK: - Public Properties
    var totalAmount: Int { items.count }
    var totalPrice: Double { items.reduce(0) { $0 + $1.price } }
    
    var onChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((ErrorModel) -> Void)?
    
    // MARK: - Private Properties
    private(set) var items: [Nft] = [] {
        didSet { onChange?() }
    }
    
    private(set) var isLoading: Bool = false {
        didSet { onLoadingChange?(isLoading) }
    }
    
    private let service: CartService
    
    // MARK: - Init
    init(service: CartService = CartServiceImpl()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func loadData() {
        isLoading = true
        
        Task {
            do {
                let fetchedNfts = try await service.loadCart()
                self.items = fetchedNfts
                self.isLoading = false
            } catch {
                self.isLoading = false
                let errorModel = ErrorModel(
                    message: "Не удалось загрузить корзину",
                    actionText: "Повторить",
                    action: { [weak self] in self?.loadData() }
                )
                onError?(errorModel)
            }
        }
    }
    
    func removeNft(_ nft: Nft) {
        isLoading = true
        
        let newItems = items.filter { $0.id != nft.id }
        let updatedIds = newItems.map { $0.id }
        
        Task {
            do {
                _ = try await service.updateCart(with: updatedIds)
                self.items = newItems
                self.isLoading = false
            } catch {
                self.isLoading = false
                let errorModel = ErrorModel(
                    message: "Не удалось удалить NFT из корзины",
                    actionText: "Повторить",
                    action: { [weak self] in
                        self?.removeNft(nft)
                    }
                )
                onError?(errorModel)
            }
        }
    }
}
