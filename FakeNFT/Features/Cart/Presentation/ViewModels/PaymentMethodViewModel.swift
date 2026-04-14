import Foundation

@MainActor
final class PaymentMethodViewModel {
    // MARK: - Public Properties
    var onCurrenciesLoaded: (([Currency]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onPaymentResult: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    private let service: CartService
    
    private(set) var currencies: [Currency] = [] {
        didSet { onCurrenciesLoaded?(currencies) }
    }
    
    private(set) var isLoading: Bool = false {
        didSet { onLoadingStateChanged?(isLoading) }
    }
    
    private var selectedCurrencyId: String?
    
    // MARK: - Init
    init(service: CartService = CartServiceImpl()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func fetchCurrencies() {
        Task {
            isLoading = true
            do {
                currencies = try await service.loadCurrencies()
            } catch {
                print("Failed to fetch currencies: \(error)")
            }
            isLoading = false
        }
    }
    
    func selectCurrency(at index: Int) {
        selectedCurrencyId = currencies[index].id
    }
    
    func pay() {
        guard let currencyId = selectedCurrencyId else { return }
        Task {
            isLoading = true
            do {
                let result = try await service.payOrder(currencyId: currencyId)
                
                if result.success {
                    try? await service.clearCart()
                    onPaymentResult?(true)
                } else {
                    onPaymentResult?(false)
                }
            } catch {
                onPaymentResult?(false)
            }
            isLoading = false
        }
    }
}
