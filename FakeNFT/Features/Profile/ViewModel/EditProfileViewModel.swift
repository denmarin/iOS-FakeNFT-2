import Foundation
import Combine

enum EditProfileState: Equatable {
    case idle
    case loading
    case error(String)
}

@MainActor
final class EditProfileViewModel{
    @Published var name: String
    @Published var description: String
    @Published var website: String
    @Published var avatar: URL?
    
    @Published var state: EditProfileState = .idle
    @Published var isChanged: Bool = false
    
    private let provider: ProfileDataProvider
    private let currentHeader: ProfileHeader
    private let currentLikes: [String]
    private let onSave: (ProfileHeader) -> Void
    
    init(header: ProfileHeader,provider: ProfileDataProvider,currentLikes: [String], onSave: @escaping (ProfileHeader) -> Void) {
        self.currentHeader = header
        self.provider = provider
        self.currentLikes = currentLikes
        self.onSave = onSave
        
        self.name = header.name
        self.description = header.description
        self.website = header.website ?? ""
        self.avatar = header.avatar
        
        setupChangeTracking()
    }
    
    private func setupChangeTracking() {
        Publishers.CombineLatest4($name, $description, $website, $avatar)
            .map { [weak self] name, desc, site, avatarAssetName in
                guard let self = self else { return false }
                return name != self.currentHeader.name ||
                desc != self.currentHeader.description ||
                site != self.currentHeader.website ||
                avatarAssetName != self.currentHeader.avatar
            }
            .assign(to: &$isChanged)
    }
    
    func didTapSave() {
        state = .loading
        
        Task {
            do {
                let updatedData = try await provider.updateProfile(
                    name: name,
                    description: description,
                    website: website,
                    avatar: avatar?.absoluteString ?? "",
                    likes: currentLikes
                )
                state = .idle
    
                onSave(updatedData.header)
                
            } catch let error as NetworkClientError {
                state = .error(error.description)
                state = .idle
                
            } catch {
                state = .error("Произошла непредвиденная ошибка")
                state = .idle
            }
            
        }
    }
    
    func updateAvatar(with newImage: URL) {
        self.avatar = newImage
    }
    
    func removeAvatar() {
        self.avatar = nil
    }
}
