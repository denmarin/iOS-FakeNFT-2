import Foundation

struct ProfileHeader: Equatable {
    let name: String
    let description: String
    let website: String?
    let avatarAssetName: URL?
}

struct NftCard: Equatable, Identifiable {
    let id: String
    let title: String
    let priceText: Double
    let rating: Int
    let imageAssetName: URL?
    let authorName: String
}

struct ProfileScreenData: Equatable {
    let header: ProfileHeader
    let myNftsIds: [String] 
    let favoritesIds: [String]
    let myNfts: [NftCard]
    let favorites: [NftCard]
}
