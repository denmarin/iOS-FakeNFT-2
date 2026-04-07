import Foundation

struct MockCatalogCollectionsProvider: CatalogCollectionsProviding {
    private let collections: [CatalogCollection]
    private let loadingDelay: Duration

    init(
        collections: [CatalogCollection] = CatalogLocalMockCollections.makeCollections(),
        loadingDelay: Duration = .milliseconds(650)
    ) {
        self.collections = collections
        self.loadingDelay = loadingDelay
    }

    func fetchCollections() async throws -> [CatalogCollection] {
        try await Task.sleep(for: loadingDelay)
        return collections
    }
}
