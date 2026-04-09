import Foundation

struct CatalogService: CatalogCollectionsProviding {
    private let networkClient: NetworkClient
    private let pageSize: Int
    private let cache: CatalogCollectionsCache

    init(
        networkClient: NetworkClient,
        pageSize: Int = 25,
        cache: CatalogCollectionsCache = CatalogCollectionsCache.shared
    ) {
        self.networkClient = networkClient
        self.pageSize = max(1, pageSize)
        self.cache = cache
    }

    func fetchCollections(
        onPartialResult: @MainActor @escaping @Sendable ([CatalogCollection]) -> Void
    ) async throws -> [CatalogCollection] {
        let cachedCollections = await cache.cachedCollections()
        if !cachedCollections.isEmpty {
            await onPartialResult(cachedCollections)
        }

        do {
            let fetchedCollections = try await fetchAllCollections(onPartialResult: onPartialResult)
            await cache.save(fetchedCollections)
            return fetchedCollections
        } catch {
            if !cachedCollections.isEmpty {
                return cachedCollections
            }
            throw error
        }
    }

    private func fetchAllCollections(
        onPartialResult: @MainActor @escaping @Sendable ([CatalogCollection]) -> Void
    ) async throws -> [CatalogCollection] {
        var allCollections: [CatalogCollection] = []
        var seenIDs: Set<String> = []
        var page = 0
        var shouldLoadNextPage = true

        while shouldLoadNextPage {
            let request = CatalogCollectionsRequest(page: page, size: pageSize)
            let response = try await networkClient.send(
                request: request,
                type: [CatalogCollectionDTO].self
            )
            let mappedCollections = response.map(\.collection)
            let uniqueCollections = mappedCollections.filter { seenIDs.insert($0.id).inserted }

            if !uniqueCollections.isEmpty {
                allCollections.append(contentsOf: uniqueCollections)
                await onPartialResult(allCollections)
            }

            let receivedFullPage = response.count == pageSize
            let hasProgress = !uniqueCollections.isEmpty
            shouldLoadNextPage = receivedFullPage && hasProgress
            page += 1
        }

        return allCollections
    }
}

private extension CatalogCollectionDTO {
    var collection: CatalogCollection {
        CatalogCollection(
            id: id,
            name: name,
            coverImageName: cover,
            nftIDs: nfts,
            description: description,
            authorName: author
        )
    }
}

actor CatalogCollectionsCache {
    static let shared = CatalogCollectionsCache()

    private var collections: [CatalogCollection] = []

    func cachedCollections() -> [CatalogCollection] {
        collections
    }

    func save(_ collections: [CatalogCollection]) {
        self.collections = collections
    }
}
