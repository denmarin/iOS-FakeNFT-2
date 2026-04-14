import Foundation

final class DeleteNftViewModel {
    // MARK: - Public Properties
    let nftImage: URL?
    
    // MARK: - Private Properties
    private let onConfirm: (Bool) -> Void
    
    // MARK: - Init
    init(nftImage: URL?, onConfirm: @escaping (Bool) -> Void) {
        self.nftImage = nftImage
        self.onConfirm = onConfirm
    }
    
    // MARK: - Public Methods
    func confirmDelete() {
        onConfirm(true)
    }
    
    func cancelDelete() {
        onConfirm(false)
    }
}
