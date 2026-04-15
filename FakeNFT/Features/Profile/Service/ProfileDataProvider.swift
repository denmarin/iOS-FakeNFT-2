import Combine
import Foundation

protocol ProfileDataProvider {
    func loadProfile() async throws -> ProfileScreenData
    func updateProfile(name: String, description: String, website: String, avatar: String, likes: [String]) async throws -> ProfileScreenData
    func loadNFTs(ids: [String]) async throws -> [NftCard]
}

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
    
    private func loadNFT(by id: String) async throws -> NftCard{
        let request = NFTGetRequest(id: id)
        let NFTResponse = try await networkClient.send(request: request, type: Nft.self)
        
        let nftCard = NftCard(id: NFTResponse.id,
                              title: NFTResponse.name,
                              price: NFTResponse.price,
                              rating: NFTResponse.rating,
                              image: NFTResponse.images.first,
                              authorName: NFTResponse.author
        )
        
        return nftCard
    }
    
    func loadNFTs(ids: [String]) async throws -> [NftCard] {
        try await withThrowingTaskGroup(of: NftCard?.self) { group in
            for id in ids {
                group.addTask {
                    do {
                        return try await self.loadNFT(by: id)
                    } catch {
                        return nil
                    }
                }
            }
            
            var nfts = [NftCard]()
            for try await nft in group {
                if let nft = nft {
                    nfts.append(nft)
                }
            }
            
            return nfts
        }
    }
}

