import Foundation

enum ProfileViewState: Equatable {
    case idle
    case loading
    case content(ProfileScreenData)
    case error(String)
}

enum ProfileRoute: Equatable {
    case editProfile(ProfileHeader)
    case myNfts([NftCard])
    case favorites([NftCard])
    case webView
}
