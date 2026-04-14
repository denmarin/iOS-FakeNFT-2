import UIKit
class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 11,
        left: 16,
        bottom: 11,
        right: 16
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}
