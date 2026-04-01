import UIKit

final class EditProfileFiledWithTextView: UIView, UITextViewDelegate{
    var onTextChanged: ((String) -> Void)?
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .ypLightGrey
        textView.font = .bodyRegular
        textView.textColor = .ypBlack
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 12
        textView.clipsToBounds = true
        textView.heightAnchor.constraint(equalToConstant: 132).isActive = true
        return textView
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
        textView.text = text
        textView.delegate = self
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textView)
        
        stackView.constraintEdges(to: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text ?? "")
    }
}
