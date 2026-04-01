import UIKit

final class EditProfileFiledWithTextField: UIView{
    var onTextChanged: ((String) -> Void)?
    
    let textField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.backgroundColor = .ypLightGrey
        textField.font = .bodyRegular
        textField.textColor = .ypBlack
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textField
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(title: String, text: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        stackView.constraintEdges(to: self)
    }
    
    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
}
