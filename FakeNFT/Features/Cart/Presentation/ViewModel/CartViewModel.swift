import Foundation

@MainActor
final class CartViewModel {
    // MARK: - Public Properties
    var totalAmount: Int { items.count }
    var totalPrice: Double { items.reduce(0) { $0 + $1.price } }
    
    var onChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    
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
                assertionFailure("Cart loading error: \(error)")
            }
        }
    }
}
