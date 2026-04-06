import Combine
import Foundation

@MainActor
final class ProfileViewModelImpl: ProfileViewModel {
    private let provider: ProfileDataProvider
    private var screenData: ProfileScreenData?
    
    private let stateSubject = CurrentValueSubject<ProfileViewState, Never>(.idle)
    private let routeSubject = PassthroughSubject<ProfileRoute, Never>()
    
    var state: AnyPublisher<ProfileViewState, Never> { stateSubject.eraseToAnyPublisher() }
    var route: AnyPublisher<ProfileRoute, Never> { routeSubject.eraseToAnyPublisher() }
    
    init(provider: ProfileDataProvider) {
        self.provider = provider
    }
    
    func onAppear() {
        stateSubject.send(.loading)
        Task {
            let data = try await provider.loadProfile()
            self.screenData = data
            self.stateSubject.send(.content(data))
        }
    }
    
    func didTapMyNfts() {
        guard let data = screenData else { return }
        routeSubject.send(.myNfts(data.myNfts))
    }
    
    func didTapFavorites() {
        guard let data = screenData else { return }
        routeSubject.send(.favorites(data.favorites))
    }
    
    func didTapEdit() {
        guard let data = screenData else { return }
        routeSubject.send(.editProfile(data.header))
    }
    
    func didTapWebsite(){
        routeSubject.send(.webView)
    }
    
    func updateHeader(_ newHeader: ProfileHeader) {
        guard let currentData = screenData else { return }
        
        let updatedData = ProfileScreenData(
            header: newHeader,
            myNftsIds: currentData.myNftsIds,
            favoritesIds: currentData.favoritesIds,
            myNfts: currentData.myNfts,
            favorites: currentData.favorites
        )
        
        self.screenData = updatedData
        self.stateSubject.send(.content(updatedData))
    }
    
    func updateFavorite(_ newFavorites: [NftCard]){
//        guard let currentData = screenData else { return }
//        
//        let updatedData = ProfileScreenData(
//            header: currentData.header,
//            myNfts: currentData.myNfts,
//            favorites: newFavorites
//        )
//        
//        self.screenData = updatedData
//        self.stateSubject.send(.content(updatedData))
    }
}
