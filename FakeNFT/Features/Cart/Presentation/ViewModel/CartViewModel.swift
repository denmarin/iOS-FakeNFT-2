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
    private let sortTypeKey = "CartSortTypeKey"
    private let userDefaults = UserDefaults.standard
    
    private var currentSortType: CartSortType {
        get {
            guard let savedValue = userDefaults.string(forKey: sortTypeKey),
                  let type = CartSortType(rawValue: savedValue) else {
                return .name
            }
            return type
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortTypeKey)
        }
    }
    
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
                self.applySort()
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
    
    func sort(by type: CartSortType) {
        currentSortType = type
        applySort()
    }
    
    // MARK: - Private Methods
    private func applySort() {
        switch currentSortType {
        case .price:
            items.sort { $0.price < $1.price }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .name:
            items.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
}
