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
    private let service: CartService
    private let storage: CartSortStorageProtocol
    
    private(set) var items: [Nft] = [] {
        didSet { onChange?() }
    }
    
    private(set) var isLoading: Bool = false {
        didSet { onLoadingChange?(isLoading) }
    }
    
    // MARK: - Init
    init(
        service: CartService = CartServiceImpl(),
        storage: CartSortStorageProtocol = CartSortStorage()
    ) {
        self.service = service
        self.storage = storage
    }
    
    // MARK: - Public Methods
    func loadData() {
        isLoading = true
        
        Task {
            do {
                let fetchedNfts = try await service.loadCart()
                self.items = fetchedNfts
                self.applySort()
                self.isLoading = false
            } catch {
                self.isLoading = false
                let errorModel = ErrorModel(
                    message: String(localized: "cart.error.loadCart", defaultValue: "Не удалось загрузить корзину"),
                    actionText: String(localized: "cart.common.retry", defaultValue: "Повторить"),
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
                    message: String(localized: "cart.error.removeNft", defaultValue: "Не удалось удалить NFT из корзины"),
                    actionText: String(localized: "cart.common.retry", defaultValue: "Повторить"),
                    action: { [weak self] in
                        self?.removeNft(nft)
                    }
                )
                onError?(errorModel)
            }
        }
    }
    
    func sort(by type: CartSortType) {
        storage.sortType = type
        applySort()
    }
    
    func refreshCart() {
        Task {
            isLoading = true
            do {
                items = try await service.loadCart()
            } catch {
                print("\(String(localized: "cart.error.refreshPrefix", defaultValue: "Ошибка обновления корзины")): \(error)")
            }
            isLoading = false
        }
    }
    
    func clearCartOnPaymentSuccess() {
        Task {
            do {
                try await service.clearCart()
                items = []
            } catch {
                let errorModel = ErrorModel(
                    message: String(localized: "cart.error.clearCart", defaultValue: "Не удалось очистить корзину"),
                    actionText: String(localized: "cart.common.retry", defaultValue: "Повторить"),
                    action: { [weak self] in self?.clearCartOnPaymentSuccess() }
                )
                onError?(errorModel)
            }
        }
    }
    
    // MARK: - Private Methods
    private func applySort() {
        switch storage.sortType {
        case .price:
            items.sort { $0.price < $1.price }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .name:
            items.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
}
