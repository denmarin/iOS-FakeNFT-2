import UIKit

final class CartBottomView: UIView {
    var onCheckoutButtonTapped: (() -> Void)?
    
    // MARK: - Private Properties
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .greenUniversal
        return label
    }()
    
    private lazy var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlack
        button.setTitle("К оплате", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCheckout), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(count: Int, price: Double) {
        countLabel.text = "\(count) NFT"
        priceLabel.text = String(format: "%.2f ETH", price).replacingOccurrences(of: ".", with: ",")
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = .ypLightGrey
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupLayout() {
        addSubview(infoStackView)
        addSubview(checkoutButton)
        
        infoStackView.addArrangedSubview(countLabel)
        infoStackView.addArrangedSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            checkoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkoutButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkoutButton.leadingAnchor.constraint(equalTo: infoStackView.trailingAnchor, constant: 24),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - @objc Methods
    @objc private func didTapCheckout() {
        onCheckoutButtonTapped?()
    }
}
