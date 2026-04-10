import Combine
import Foundation

@MainActor
protocol ProfileViewModel {
    var state: AnyPublisher<ProfileViewState, Never> { get }
    var route: AnyPublisher<ProfileRoute, Never> { get }
    
    func onAppear()
    func didTapMyNfts()
    func didTapFavorites()
    func didTapEdit()
    func didTapWebsite()
    func updateHeader(_ newHeader: ProfileHeader)
    func updateFavorite(_ newFavorites: [NftCard],_ newFavoritesIds: [String])
}
