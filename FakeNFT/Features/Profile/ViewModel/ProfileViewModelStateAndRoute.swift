import Foundation

enum ProfileViewState: Equatable {
    case idle
    case loading
    case content(ProfileScreenData)
    case error(String)
}

enum ProfileRoute: Equatable {
    case editProfile(ProfileScreenData)
    case myNfts(ProfileScreenData)
    case favorites(ProfileScreenData)
    case webView
}
