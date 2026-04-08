import Combine
import Foundation

protocol ProfileDataProvider {
    func loadProfile() async throws -> ProfileScreenData
    func updateProfile(name: String, description: String, website: String, avatar: String, likes: [String]) async throws -> ProfileScreenData
}

//final class ProfileMockService: ProfileDataProvider {
//    func loadProfile() async -> ProfileScreenData {
//        try? await Task.sleep(nanoseconds: 250_000_000)
//        return ProfileScreenData(
//            header: ProfileHeader(
//                name: "Joaquin Phoenix",
//                description: "Дизайнер из Казани, работаю много лет в этой сфере рад пообщаться и к новым приключениям вот бы было круто погулять по городу.",
//                website: "example.com",
//                avatarAssetName: "mockAvatar"
//            ),
//            myNfts: [
//                NftCard(id: "1", title: "Lilo", priceText: "1,78 ETH", rating: 3, imageAssetName: "lilo", authorName: "John Doe"),
//                NftCard(id: "4", title: "Spring", priceText: "2,78 ETH", rating: 4, imageAssetName: "spring", authorName: "John Doe"),
//                NftCard(id: "5", title: "Melissa", priceText: "0,78 ETH", rating: 5, imageAssetName: "melissa", authorName: "John Doe")
//            ],
//            favorites: [
//                NftCard(id: "2", title: "April", priceText: "1,78 ETH", rating: 5, imageAssetName: "april", authorName: "John Doe"),
//                NftCard(id: "3", title: "Pixi", priceText: "1,78 ETH", rating: 2, imageAssetName: "pixi", authorName: "John Doe")
//            ]
//        )
//    }
//}


final class ProfileServiceImp: ProfileDataProvider {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func loadProfile() async throws -> ProfileScreenData {
        let profileDto = try await networkClient.send(request: ProfileGetRequest(), type: Profile.self)
                
        let profileHeader = ProfileHeader(
            name: profileDto.name,
            description: profileDto.description ?? "",
            website: profileDto.website ?? "",
            avatar: profileDto.avatar)
        
        return ProfileScreenData(
            header: profileHeader,
            myNftsIds: profileDto.nfts,
            favoritesIds: profileDto.likes,
            myNfts: [],
            favorites: []
        )
    }
    
    func updateProfile(name: String, description: String, website: String, avatar: String, likes: [String]) async throws -> ProfileScreenData {
        
        let dto = ProfileUpdateDto(name: name, description: description, avatar: avatar, website: website, likes: likes)
        
        let request = ProfilePutRequest(dto: dto)
        
        print(request)
        
        let profileResponse = try await networkClient.send(request: request, type: Profile.self)
        
        let profileHeader = ProfileHeader(
            name: profileResponse.name,
            description: profileResponse.description ?? "",
            website: profileResponse.website ?? "",
            avatar: profileResponse.avatar)
        
        return ProfileScreenData(
            header: profileHeader,
            myNftsIds: profileResponse.nfts,
            favoritesIds: profileResponse.likes,
            myNfts: [],
            favorites: []
        )
    }
}
