import Foundation

protocol SuccessViewModelProtocol {
    var onReturn: (() -> Void)? { get set }
    func didTapReturn()
}

final class SuccessViewModel: SuccessViewModelProtocol {
    var onReturn: (() -> Void)?
    
    func didTapReturn() {
        onReturn?()
    }
}
