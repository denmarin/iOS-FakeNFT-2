import UIKit

final class SuccessViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: SuccessViewModelProtocol
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "successPay")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "cart.success.message", defaultValue: "Успех! Оплата прошла,\nпоздравляем с покупкой!")
        label.font = .headline3
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlack
        button.setTitle(String(localized: "cart.success.returnToCart", defaultValue: "Вернуться в корзину"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapReturn), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(viewModel: SuccessViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayout()
    }
    
    // MARK: - Private Methods
    private func setupLayout() {
        [imageView, successLabel, returnButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            imageView.heightAnchor.constraint(equalToConstant: 278),
            
            successLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            successLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            successLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            returnButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            returnButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            returnButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - @objc Methods
    @objc private func didTapReturn() {
        viewModel.didTapReturn()
    }
}
