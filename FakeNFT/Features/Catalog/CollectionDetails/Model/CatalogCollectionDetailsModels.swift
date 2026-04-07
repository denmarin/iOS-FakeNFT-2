import Foundation

struct CatalogCollectionDetailsHeaderViewModel: Sendable {
    let title: String
    let coverImageName: String
    let description: String
    let authorName: String
}

struct CatalogCollectionNftCellViewModel: Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let priceText: String
    let isFavorite: Bool
    let isInCart: Bool
}

enum CatalogCollectionDetailsViewState {
    case loading
    case content([CatalogCollectionNftCellViewModel])
    case failed(message: String)
}
