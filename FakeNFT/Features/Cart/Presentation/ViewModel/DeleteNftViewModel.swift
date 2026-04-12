import Foundation

final class DeleteNftViewModel {
    let nftImage: URL?
    
    private let onConfirm: (Bool) -> Void
    
    init(nftImage: URL?, onConfirm: @escaping (Bool) -> Void) {
        self.nftImage = nftImage
        self.onConfirm = onConfirm
    }
    
    func confirmDelete() {
        onConfirm(true)
    }
    
    func cancelDelete() {
        onConfirm(false)
    }
}
