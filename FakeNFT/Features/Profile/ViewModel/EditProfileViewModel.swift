import Foundation
import Combine

@MainActor
final class EditProfileViewModel{
    @Published var name: String
    @Published var description: String
    @Published var website: String
    @Published var avatarAssetName: String
    
    @Published var isChanged: Bool = false
    
    private let currentHeader: ProfileHeader
    private let onSave: (ProfileHeader) -> Void
    
    init(header: ProfileHeader, onSave: @escaping (ProfileHeader) -> Void) {
        self.currentHeader = header
        self.onSave = onSave
        
        self.name = header.name
        self.description = header.description
        self.website = header.website
        self.avatarAssetName = header.avatarAssetName
        
        setupChangeTracking()
    }
    
    private func setupChangeTracking() {
        Publishers.CombineLatest4($name, $description, $website, $avatarAssetName)
            .map { [weak self] name, desc, site, avatarAssetName in
                guard let self = self else { return false }
                return name != self.currentHeader.name ||
                desc != self.currentHeader.description ||
                site != self.currentHeader.website ||
                avatarAssetName != self.currentHeader.avatarAssetName
            }
            .assign(to: &$isChanged)
    }
    
    func didTapSave() {
        let updatedHeader = ProfileHeader(
            name: name,
            description: description,
            website: website,
            avatarAssetName: avatarAssetName
        )
        
        onSave(updatedHeader)
    }
    
    func updateAvatar(with newAssetName: String) {
        self.avatarAssetName = newAssetName
    }
    
    func removeAvatar() {
        self.avatarAssetName = "profileImagePlaceholder"
    }
}
