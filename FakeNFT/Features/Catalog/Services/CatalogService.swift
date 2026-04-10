import Foundation

struct CatalogService: CatalogCollectionsProviding {
    private let networkClient: NetworkClient
    private let pageSize: Int

    init(
        networkClient: NetworkClient,
        pageSize: Int = 25
    ) {
        self.networkClient = networkClient
        self.pageSize = max(1, pageSize)
    }

    func fetchCollectionsPage(
        page: Int,
        sortBy: CatalogCollectionsSort?
    ) async throws -> CatalogCollectionsPage {
        let request = CatalogCollectionsRequest(page: page, size: pageSize, sortBy: sortBy)
        let response = try await networkClient.send(
            request: request,
            type: [CatalogCollectionDTO].self
        )
        let collections = response.map(\.collection)
        let hasNextPage = response.count == pageSize
        return CatalogCollectionsPage(collections: collections, hasNextPage: hasNextPage)
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
