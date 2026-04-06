import Foundation

struct ProfileHeader: Equatable {
    let name: String
    let description: String
    let website: String
    let avatarAssetName: String
}

struct NftCard: Equatable, Identifiable {
    let id: String
    let title: String
    let priceText: String
    let rating: Int
    let imageAssetName: String
    let authorName: String
}

struct ProfileScreenData: Equatable {
    let header: ProfileHeader
    let myNfts: [NftCard]
    let favorites: [NftCard]
}
