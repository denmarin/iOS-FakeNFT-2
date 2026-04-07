import Foundation

struct MockCatalogCollectionNftsProvider: CatalogCollectionNftsProviding {
    private let loadingDelay: Duration

    init(loadingDelay: Duration = .milliseconds(450)) {
        self.loadingDelay = loadingDelay
    }

    func fetchNfts(for collection: CatalogCollection) async throws -> [Nft] {
        try await Task.sleep(for: loadingDelay)
        return collection.nftIDs.enumerated().map { index, nftID in
            Nft(
                id: nftID,
                images: makeImageURLs(collectionID: collection.id, nftID: nftID),
                name: CatalogLocalMockCollections.nftName(from: nftID, collectionID: collection.id),
                price: makePrice(for: index),
                rating: (index % 5) + 1,
                author: collection.authorName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                    .replacingOccurrences(of: " ", with: "-"),
                description: collection.description,
                website: Self.defaultWebsiteURL
            )
        }
    }

    private func makeImageURLs(collectionID: String, nftID: String) -> [URL] {
        CatalogLocalMockCollections.makeImageURLs(collectionID: collectionID, nftID: nftID)
    }

    private func makePrice(for index: Int) -> Double {
        let baseValue = Double((index % 4) + 1)
        let fraction = Double((index * 7) % 100) / 100
        return baseValue + fraction
    }

    private static let defaultWebsiteURL = URL(string: "https://practicum.yandex.ru")!
}
