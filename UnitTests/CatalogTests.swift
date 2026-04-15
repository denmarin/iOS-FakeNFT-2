@testable import FakeNFT
import XCTest

final class CatalogTests: XCTestCase {
    // MARK: - CatalogViewModel

    @MainActor
    func testViewDidLoad_EmitsLoadingAsInitialState() async {
        let service = MockCatalogService(
            queuedResults: [
                .success(
                    CatalogCollectionsPage(
                        collections: [makeCollection()],
                        hasNextPage: false
                    )
                )
            ]
        )
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: MockCatalogSortStorage()
        )

        var states: [CatalogViewState] = []
        let firstStateExpectation = expectation(description: "First state emitted")

        viewModel.onStateChange = { state in
            states.append(state)
            if states.count == 1 {
                firstStateExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [firstStateExpectation], timeout: 1.0)
        let firstState = try? XCTUnwrap(states.first)
        if let firstState {
            assertLoading(firstState)
        } else {
            XCTFail("Expected at least one state")
        }
    }

    @MainActor
    func testViewDidLoad_WhenServiceReturnsCollections_EmitsContentState() async {
        let collection = makeCollection(
            id: "collection-1",
            name: "Crypto Kitties",
            coverImageName: "kitty-cover",
            nftIDs: ["nft-1", "nft-2"]
        )
        let service = MockCatalogService(
            queuedResults: [
                .success(
                    CatalogCollectionsPage(
                        collections: [collection],
                        hasNextPage: false
                    )
                )
            ]
        )
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: MockCatalogSortStorage()
        )

        var states: [CatalogViewState] = []
        let contentExpectation = expectation(description: "Content state emitted")

        viewModel.onStateChange = { state in
            states.append(state)
            if case .content = state {
                contentExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [contentExpectation], timeout: 1.0)

        let firstState = try? XCTUnwrap(states.first)
        let lastState = try? XCTUnwrap(states.last)

        if let firstState {
            assertLoading(firstState)
        } else {
            XCTFail("Expected at least one state")
        }

        guard let lastState else {
            XCTFail("Expected final state")
            return
        }

        guard case let .content(cellModels) = lastState else {
            XCTFail("Expected content state")
            return
        }

        XCTAssertEqual(
            cellModels,
            [
                CatalogCollectionCellViewModel(
                    id: "collection-1",
                    name: "Crypto Kitties",
                    coverImageName: "kitty-cover",
                    nftCount: 2
                )
            ]
        )
    }

    @MainActor
    func testViewDidLoad_WhenSortByNftCount_EmitsCollectionsSortedByNftCountDesc() async {
        let oneNft = makeCollection(id: "one", name: "One", nftIDs: ["n1"])
        let fourNfts = makeCollection(id: "four", name: "Four", nftIDs: ["n1", "n2", "n3", "n4"])
        let twoNfts = makeCollection(id: "two", name: "Two", nftIDs: ["n1", "n2"])

        let service = MockCatalogService(
            queuedResults: [
                .success(
                    CatalogCollectionsPage(
                        collections: [oneNft, fourNfts, twoNfts],
                        hasNextPage: false
                    )
                )
            ]
        )
        let sortStorage = MockCatalogSortStorage()
        sortStorage.sortOption = .byNftCount
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: sortStorage
        )

        var received: [CatalogCollectionCellViewModel] = []
        let contentExpectation = expectation(description: "Content state emitted")

        viewModel.onStateChange = { state in
            if case let .content(cellModels) = state {
                received = cellModels
                contentExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [contentExpectation], timeout: 1.0)

        XCTAssertEqual(received.map(\.id), ["four", "two", "one"])
        XCTAssertEqual(received.map(\.nftCount), [4, 2, 1])
    }

    @MainActor
    func testViewDidLoad_WhenServiceReturnsEmptyPage_EmitsEmptyState() async {
        let service = MockCatalogService(
            queuedResults: [
                .success(
                    CatalogCollectionsPage(
                        collections: [],
                        hasNextPage: false
                    )
                )
            ]
        )
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: MockCatalogSortStorage()
        )

        var states: [CatalogViewState] = []
        let emptyExpectation = expectation(description: "Empty state emitted")

        viewModel.onStateChange = { state in
            states.append(state)
            if case .empty = state {
                emptyExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [emptyExpectation], timeout: 1.0)

        let firstState = try? XCTUnwrap(states.first)
        let lastState = try? XCTUnwrap(states.last)

        if let firstState {
            assertLoading(firstState)
        } else {
            XCTFail("Expected at least one state")
        }

        if let lastState {
            assertEmpty(lastState)
        } else {
            XCTFail("Expected final state")
        }
    }

    @MainActor
    func testViewDidLoad_WhenServiceFails_EmitsErrorState() async {
        let service = MockCatalogService(
            queuedResults: [
                .failure(MockCatalogServiceError.stubbedFailure)
            ]
        )
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: MockCatalogSortStorage()
        )

        var states: [CatalogViewState] = []
        let errorExpectation = expectation(description: "Error state emitted")

        viewModel.onStateChange = { state in
            states.append(state)
            if case .error = state {
                errorExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()

        await fulfillment(of: [errorExpectation], timeout: 1.0)

        let firstState = try? XCTUnwrap(states.first)
        let lastState = try? XCTUnwrap(states.last)

        if let firstState {
            assertLoading(firstState)
        } else {
            XCTFail("Expected at least one state")
        }

        guard let lastState else {
            XCTFail("Expected final state")
            return
        }

        guard case let .error(message) = lastState else {
            XCTFail("Expected error state")
            return
        }

        XCTAssertEqual(message, String(localized: "catalog.collection.load.error"))
    }

    @MainActor
    func testRetryLoading_AfterInitialError_EmitsContentState() async {
        let expectedCollection = makeCollection(
            id: "retry-collection",
            name: "Retry Collection",
            coverImageName: "retry-cover",
            nftIDs: ["nft-1"]
        )
        let service = MockCatalogService(
            queuedResults: [
                .failure(MockCatalogServiceError.stubbedFailure),
                .success(
                    CatalogCollectionsPage(
                        collections: [expectedCollection],
                        hasNextPage: false
                    )
                )
            ]
        )
        let viewModel = CatalogViewModel(
            collectionsProvider: service,
            sortStorage: MockCatalogSortStorage()
        )

        var states: [CatalogViewState] = []
        var didCallRetry = false
        let firstErrorExpectation = expectation(description: "First error state emitted")
        let contentAfterRetryExpectation = expectation(description: "Content state emitted after retry")

        viewModel.onStateChange = { state in
            states.append(state)
            if case .error = state {
                firstErrorExpectation.fulfill()
            }
            if didCallRetry, case .content = state {
                contentAfterRetryExpectation.fulfill()
            }
        }

        viewModel.viewDidLoad()
        await fulfillment(of: [firstErrorExpectation], timeout: 1.0)

        didCallRetry = true
        viewModel.retryLoading()

        await fulfillment(of: [contentAfterRetryExpectation], timeout: 1.0)

        XCTAssertEqual(service.receivedRequests.map { $0.page }, [0, 0])
        XCTAssertEqual(states.map(\.kind), [.loading, .error, .loading, .content])

        guard case let .content(cellModels) = states.last else {
            XCTFail("Expected content state")
            return
        }

        XCTAssertEqual(
            cellModels,
            [
                CatalogCollectionCellViewModel(
                    id: "retry-collection",
                    name: "Retry Collection",
                    coverImageName: "retry-cover",
                    nftCount: 1
                )
            ]
        )
    }

    // MARK: - CatalogService

    func testCatalogService_WhenNetworkReturnsDTOs_ReturnsMappedCollectionsAndHasNextPageTrue() async throws {
        let dto1 = makeDTO(
            id: "dto-1",
            name: "First",
            cover: "cover-1",
            nfts: ["nft-1", "nft-2"],
            description: "Description 1",
            author: "Author 1"
        )
        let dto2 = makeDTO(
            id: "dto-2",
            name: "Second",
            cover: "cover-2",
            nfts: ["nft-3"],
            description: "Description 2",
            author: "Author 2"
        )
        let networkClient = MockNetworkClient(result: .success([dto1, dto2]))
        let service = CatalogService(networkClient: networkClient, pageSize: 2)

        let page = try await service.fetchCollectionsPage(page: 1, sortBy: .byNameAscending)

        XCTAssertTrue(page.hasNextPage)
        XCTAssertEqual(page.collections.count, 2)
        XCTAssertEqual(
            page.collections,
            [
                CatalogCollection(
                    id: "dto-1",
                    name: "First",
                    coverImageName: "cover-1",
                    nftIDs: ["nft-1", "nft-2"],
                    description: "Description 1",
                    authorName: "Author 1"
                ),
                CatalogCollection(
                    id: "dto-2",
                    name: "Second",
                    coverImageName: "cover-2",
                    nftIDs: ["nft-3"],
                    description: "Description 2",
                    authorName: "Author 2"
                )
            ]
        )

        let capturedRequest = try XCTUnwrap(networkClient.capturedRequest)
        XCTAssertEqual(capturedRequest.page, 1)
        XCTAssertEqual(capturedRequest.size, 2)
        XCTAssertEqual(capturedRequest.sortBy, .byNameAscending)
    }

    func testCatalogService_WhenNetworkFails_ThrowsUnderlyingError() async {
        let networkClient = MockNetworkClient(result: .failure(MockNetworkClientError.stubbedFailure))
        let service = CatalogService(networkClient: networkClient, pageSize: 2)

        do {
            _ = try await service.fetchCollectionsPage(page: 0, sortBy: nil)
            XCTFail("Expected fetchCollectionsPage to throw")
        } catch let error as MockNetworkClientError {
            XCTAssertEqual(error, .stubbedFailure)
        } catch {
            XCTFail("Expected MockNetworkClientError, got: \(error)")
        }
    }

    func testCatalogService_MappingEdgeCase_WithEmptyNFTs_MapsNftCountToZeroAndHasNextPageFalse() async throws {
        let dto = makeDTO(
            id: "dto-empty",
            name: "Empty NFTs",
            cover: "cover-empty",
            nfts: [],
            description: "No NFTs",
            author: "Edge Author"
        )
        let networkClient = MockNetworkClient(result: .success([dto]))
        let service = CatalogService(networkClient: networkClient, pageSize: 2)

        let page = try await service.fetchCollectionsPage(page: 0, sortBy: nil)

        XCTAssertFalse(page.hasNextPage)
        let collection = try XCTUnwrap(page.collections.first)
        XCTAssertEqual(collection.id, "dto-empty")
        XCTAssertEqual(collection.name, "Empty NFTs")
        XCTAssertEqual(collection.coverImageName, "cover-empty")
        XCTAssertEqual(collection.description, "No NFTs")
        XCTAssertEqual(collection.authorName, "Edge Author")
        XCTAssertEqual(collection.nftIDs, [])
        XCTAssertEqual(collection.nftCount, 0)
    }
}

// MARK: - Mocks

private final class MockCatalogService: CatalogCollectionsProviding {
    private(set) var receivedRequests: [(page: Int, sortBy: CatalogCollectionsSort?)] = []
    private var queuedResults: [Result<CatalogCollectionsPage, Error>]

    init(queuedResults: [Result<CatalogCollectionsPage, Error>]) {
        self.queuedResults = queuedResults
    }

    func fetchCollectionsPage(
        page: Int,
        sortBy: CatalogCollectionsSort?
    ) async throws -> CatalogCollectionsPage {
        receivedRequests.append((page, sortBy))
        guard !queuedResults.isEmpty else {
            throw MockCatalogServiceError.missingStub
        }
        return try queuedResults.removeFirst().get()
    }
}

private final class MockCatalogSortStorage: CatalogSortStorageProtocol {
    var sortOption: CatalogSortOption = .byNftCount
}

private enum MockCatalogServiceError: Error {
    case stubbedFailure
    case missingStub
}

private final class MockNetworkClient: NetworkClient {
    private let result: Result<[CatalogCollectionDTO], Error>
    private(set) var capturedRequest: CatalogCollectionsRequest?

    init(result: Result<[CatalogCollectionDTO], Error>) {
        self.result = result
    }

    @discardableResult
    func send(
        request _: NetworkRequest,
        completionQueue _: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        onResponse(.failure(MockNetworkClientError.unsupportedCallbackAPI))
        return nil
    }

    @discardableResult
    func send<T: Decodable>(
        request _: NetworkRequest,
        type _: T.Type,
        completionQueue _: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        onResponse(.failure(MockNetworkClientError.unsupportedCallbackAPI))
        return nil
    }

    func send<T: Decodable>(request: NetworkRequest, type _: T.Type) async throws -> T {
        capturedRequest = request as? CatalogCollectionsRequest

        switch result {
        case let .success(dto):
            guard let typedResponse = dto as? T else {
                throw MockNetworkClientError.typeMismatch
            }
            return typedResponse
        case let .failure(error):
            throw error
        }
    }
}

private enum MockNetworkClientError: Error, Equatable {
    case stubbedFailure
    case unsupportedCallbackAPI
    case typeMismatch
}

// MARK: - Test Helpers

private extension CatalogTests {
    func makeCollection(
        id: String = "collection-id",
        name: String = "Collection name",
        coverImageName: String = "cover-image",
        nftIDs: [String] = ["nft-1"],
        description: String = "Description",
        authorName: String = "Author"
    ) -> CatalogCollection {
        CatalogCollection(
            id: id,
            name: name,
            coverImageName: coverImageName,
            nftIDs: nftIDs,
            description: description,
            authorName: authorName
        )
    }

    func makeDTO(
        id: String,
        name: String,
        cover: String,
        nfts: [String],
        description: String,
        author: String
    ) -> CatalogCollectionDTO {
        CatalogCollectionDTO(
            name: name,
            cover: cover,
            nfts: nfts,
            description: description,
            author: author,
            id: id
        )
    }

    func assertLoading(
        _ state: CatalogViewState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .loading = state else {
            XCTFail("Expected loading state", file: file, line: line)
            return
        }
    }

    func assertEmpty(
        _ state: CatalogViewState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .empty = state else {
            XCTFail("Expected empty state", file: file, line: line)
            return
        }
    }
}

private extension CatalogViewState {
    var kind: CatalogViewStateKind {
        switch self {
        case .loading:
            .loading
        case .content:
            .content
        case .empty:
            .empty
        case .error:
            .error
        }
    }
}

private enum CatalogViewStateKind: Equatable {
    case loading
    case content
    case empty
    case error
}
