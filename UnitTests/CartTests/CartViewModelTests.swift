import XCTest
@testable import FakeNFT

// MARK: - Mocks
final class CartServiceMock: CartService {
    private(set) var loadCartCalled = false
    private(set) var clearCartCalled = false

    var shouldReturnError = false
    var stubNfts: [Nft] = []

    func loadCart() async throws -> [Nft] {
        loadCartCalled = true
        if shouldReturnError {
            throw URLError(.cannotConnectToHost)
        }
        return stubNfts
    }

    func updateCart(with nftIds: [String]) async throws -> Order {
        Order(nfts: nftIds, id: "1")
    }

    func loadCurrencies() async throws -> [Currency] {
        []
    }

    func payOrder(currencyId: String) async throws -> OrderPayment {
        OrderPayment(success: true, orderId: "1", id: currencyId)
    }

    func clearCart() async throws {
        clearCartCalled = true
    }
}

final class CartSortStorageMock: CartSortStorageProtocol {
    var sortType: CartSortType = .name
}

// MARK: - Helpers
private enum TestFixtures {
    static let sampleURL = URL(string: "https://example.com/nft.png")!
    static let sampleWebsite = URL(string: "https://example.com")!

    static func nft(id: String, name: String, price: Double, rating: Int) -> Nft {
        Nft(
            id: id,
            images: [sampleURL],
            name: name,
            price: price,
            rating: rating,
            author: "author-\(id)",
            description: "desc",
            website: sampleWebsite
        )
    }
}

// MARK: - Tests
@MainActor
final class CartViewModelTests: XCTestCase {

    func testLoadCartSuccess() async {
        // Given
        let mock = CartServiceMock()
        mock.shouldReturnError = false
        mock.stubNfts = [
            TestFixtures.nft(id: "b", name: "B", price: 2, rating: 3),
            TestFixtures.nft(id: "a", name: "A", price: 1, rating: 5)
        ]
        let storage = CartSortStorageMock()
        let sut = CartViewModel(service: mock, storage: storage)

        var loadingStates: [Bool] = []
        let loadFinished = expectation(description: "isLoading стал false после загрузки")
        sut.onLoadingChange = { loading in
            loadingStates.append(loading)
            if !loading {
                loadFinished.fulfill()
            }
        }

        // When
        sut.loadData()
        await fulfillment(of: [loadFinished], timeout: 2)

        // Then
        XCTAssertTrue(mock.loadCartCalled)
        XCTAssertEqual(loadingStates, [true, false], "isLoading должен перейти true → false")
        XCTAssertEqual(sut.totalAmount, 2)
        XCTAssertEqual(sut.items.map(\.id), ["a", "b"], "после загрузки items (NFT в корзине) должны быть заполнены и отсортированы по имени (CartSortType.name)")
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadCartFailure() async {
        // Given
        let mock = CartServiceMock()
        mock.shouldReturnError = true
        let sut = CartViewModel(service: mock, storage: CartSortStorageMock())

        let loadFinished = expectation(description: "isLoading стал false после ошибки")
        sut.onLoadingChange = { loading in
            if !loading {
                loadFinished.fulfill()
            }
        }

        // When
        sut.loadData()
        await fulfillment(of: [loadFinished], timeout: 2)

        // Then
        XCTAssertTrue(mock.loadCartCalled)
        XCTAssertTrue(sut.items.isEmpty, "при ошибке массив NFT в корзине (items) пуст")
        XCTAssertFalse(sut.isLoading)
    }

    func testClearCartOnSuccess() async throws {
        // Given
        let mock = CartServiceMock()
        mock.shouldReturnError = false
        let sut = CartViewModel(service: mock, storage: CartSortStorageMock())

        // When
        sut.clearCartOnPaymentSuccess()
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then
        XCTAssertTrue(mock.clearCartCalled, "метод clearCart() сервиса должен быть вызван")
    }
}
