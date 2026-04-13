import XCTest
@testable import FakeNFT

// MARK: - NetworkClientMock
final class NetworkClientMock: NetworkClient {
    private(set) var capturedRequests: [NetworkRequest] = []

    var payOrderResult: OrderPayment = OrderPayment(success: true, orderId: "1", id: "payment-1")
    var payOrderError: Error?

    func send(
        request: NetworkRequest,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        nil
    }

    func send<T: Decodable>(
        request: NetworkRequest,
        type: T.Type,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        nil
    }

    func send<T: Decodable>(request: NetworkRequest, type: T.Type) async throws -> T {
        capturedRequests.append(request)
        if let payOrderError {
            throw payOrderError
        }
        if T.self == OrderPayment.self, let value = payOrderResult as? T {
            return value
        }
        throw NetworkClientError.parsingError
    }
}

// MARK: - Tests
final class CartServiceTests: XCTestCase {

    func testPaymentRequestUsesCorrectURLAndGETMethod() {
        // Given
        let currencyId = "test-currency-id"
        let expectedURL = URL(
            string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyId)"
        )

        // When
        let request = PaymentRequest(currencyId: currencyId)

        // Then
        XCTAssertEqual(request.endpoint, expectedURL)
        XCTAssertEqual(request.httpMethod, .get)
    }

    func testPayOrderUsesPaymentRequestWithNetworkClient() async throws {
        // Given
        let networkClient = NetworkClientMock()
        let sut = CartServiceImpl(networkClient: networkClient)
        let currencyId = "usd-42"

        // When
        _ = try await sut.payOrder(currencyId: currencyId)

        // Then
        XCTAssertEqual(networkClient.capturedRequests.count, 1)
        let sent = networkClient.capturedRequests.first
        XCTAssertTrue(sent is PaymentRequest, "должен уйти именно PaymentRequest")
        let paymentRequest = sent as? PaymentRequest
        XCTAssertEqual(paymentRequest?.currencyId, currencyId)
        XCTAssertEqual(
            paymentRequest?.endpoint?.absoluteString,
            "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyId)"
        )
        XCTAssertEqual(paymentRequest?.httpMethod, .get)
    }
}
