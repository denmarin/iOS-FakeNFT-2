import Foundation

struct ProfileHeader: Equatable {
    let name: String
    let description: String
    let website: String?
    let avatar: URL?
}

struct NftCard: Equatable, Identifiable {
    let id: String
    let title: String
    let priceText: Double
    let rating: Int
    let image: URL?
    let authorName: String
}

struct ProfileScreenData: Equatable {
    let header: ProfileHeader
    let myNftsIds: [String] 
    let favoritesIds: [String]
    let myNfts: [NftCard]
    let favorites: [NftCard]
}
