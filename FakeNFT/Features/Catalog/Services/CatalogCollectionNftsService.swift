import Foundation

struct CatalogCollectionNftsService: CatalogCollectionNftsProviding {
    private struct PreparedIDs {
        let uniqueIDs: [String]
        let positionsByID: [String: [Int]]

        init(_ ids: [String]) {
            var uniqueIDs: [String] = []
            var positionsByID: [String: [Int]] = [:]

            for (index, id) in ids.enumerated() {
                if positionsByID[id] == nil {
                    uniqueIDs.append(id)
                }
                positionsByID[id, default: []].append(index)
            }

            self.uniqueIDs = uniqueIDs
            self.positionsByID = positionsByID
        }
    }

    private typealias NftsStreamContinuation = AsyncThrowingStream<[Nft], Error>.Continuation

    private let loader: CatalogNftLoader
    private let cache: CatalogNftCache
    private let maxConcurrentRequests: Int

    init(
        networkClient: NetworkClient,
        maxConcurrentRequests: Int = 10
    ) {
        self.loader = CatalogNftLoader(networkClient: networkClient)
        self.maxConcurrentRequests = max(1, maxConcurrentRequests)
        self.cache = CatalogNftCache()
    }

    func nftsStream(for collection: CatalogCollection) -> AsyncThrowingStream<[Nft], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await streamNfts(for: collection, continuation: continuation)
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private func streamNfts(
        for collection: CatalogCollection,
        continuation: NftsStreamContinuation
    ) async throws {
        let ids = collection.nftIDs
        guard !ids.isEmpty else {
            continuation.yield([])
            return
        }

        let prepared = PreparedIDs(ids)
        var orderedNfts = Array<Nft?>(repeating: nil, count: ids.count)
        var lastPublishedCount = 0

        let cachedByID = await cache.cachedNfts(for: prepared.uniqueIDs)
        applyCachedNfts(cachedByID, to: &orderedNfts, positionsByID: prepared.positionsByID)
        publishNftsIfNeeded(orderedNfts, lastPublishedCount: &lastPublishedCount, continuation: continuation)

        let pendingIDs = prepared.uniqueIDs.filter { cachedByID[$0] == nil }
        guard !pendingIDs.isEmpty else {
            publishNftsIfNeeded(orderedNfts, lastPublishedCount: &lastPublishedCount, continuation: continuation)
            return
        }

        let loader = self.loader
        let cache = self.cache
        let positionsByID = prepared.positionsByID

        var nextPendingIndex = 0
        try await withThrowingTaskGroup(of: (String, Nft).self) { group in
            let initialTaskCount = min(maxConcurrentRequests, pendingIDs.count)
            for _ in 0..<initialTaskCount {
                let id = pendingIDs[nextPendingIndex]
                nextPendingIndex += 1
                addLoadTask(for: id, to: &group, loader: loader, cache: cache)
            }

            while let (id, nft) = try await group.next() {
                fillOrderedNfts(
                    orderedNfts: &orderedNfts,
                    with: nft,
                    for: id,
                    positionsByID: positionsByID
                )
                publishNftsIfNeeded(orderedNfts, lastPublishedCount: &lastPublishedCount, continuation: continuation)

                if nextPendingIndex < pendingIDs.count {
                    let id = pendingIDs[nextPendingIndex]
                    nextPendingIndex += 1
                    addLoadTask(for: id, to: &group, loader: loader, cache: cache)
                }
            }
        }

        publishNftsIfNeeded(orderedNfts, lastPublishedCount: &lastPublishedCount, continuation: continuation)
    }

    private func fillOrderedNfts(
        orderedNfts: inout [Nft?],
        with nft: Nft,
        for id: String,
        positionsByID: [String: [Int]]
    ) {
        guard let positions = positionsByID[id] else { return }
        for position in positions {
            orderedNfts[position] = nft
        }
    }

    private func applyCachedNfts(
        _ cachedByID: [String: Nft],
        to orderedNfts: inout [Nft?],
        positionsByID: [String: [Int]]
    ) {
        for (id, nft) in cachedByID {
            fillOrderedNfts(
                orderedNfts: &orderedNfts,
                with: nft,
                for: id,
                positionsByID: positionsByID
            )
        }
    }

    private func publishNftsIfNeeded(
        _ orderedNfts: [Nft?],
        lastPublishedCount: inout Int,
        continuation: NftsStreamContinuation
    ) {
        let publishedNfts = orderedNfts.compactMap { $0 }
        guard publishedNfts.count != lastPublishedCount else { return }
        lastPublishedCount = publishedNfts.count
        continuation.yield(publishedNfts)
    }

    private func addLoadTask(
        for id: String,
        to group: inout ThrowingTaskGroup<(String, Nft), Error>,
        loader: CatalogNftLoader,
        cache: CatalogNftCache
    ) {
        group.addTask(priority: .userInitiated) {
            let nft = try await loader.loadNft(withID: id)
            await cache.save(nft)
            return (id, nft)
        }
    }
}

private actor CatalogNftCache {
    private var storage: [String: Nft] = [:]

    func save(_ nft: Nft) {
        storage[nft.id] = nft
    }

    func cachedNfts(for ids: [String]) -> [String: Nft] {
        var result: [String: Nft] = [:]
        result.reserveCapacity(ids.count)

        for id in ids {
            if let nft = storage[id] {
                result[id] = nft
            }
        }

        return result
    }
}

private actor CatalogNftLoader {
    private let networkClient: NetworkClient
    private var inFlightTasks: [String: Task<Nft, Error>] = [:]

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadNft(withID id: String) async throws -> Nft {
        if let task = inFlightTasks[id] {
            return try await task.value
        }

        let task = Task {
            try await loadNftFromNetwork(withID: id)
        }
        inFlightTasks[id] = task
        defer { inFlightTasks[id] = nil }

        do {
            return try await task.value
        } catch {
            task.cancel()
            throw error
        }
    }

    private func loadNftFromNetwork(withID id: String) async throws -> Nft {
        let request = CatalogNftByIDRequest(id: id)
        return try await networkClient.send(request: request, type: Nft.self)
    }
}
