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
        label.font = .caption1
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .greenUniversal
        return label
    }()
    
    private lazy var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlack
        button.setTitle(String(localized: "cart.bottom.checkout", defaultValue: "К оплате"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .bodyBold
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
        let countFormat = String(localized: "cart.bottom.nftCountFormat", defaultValue: "%lld NFT")
        countLabel.text = String(format: countFormat, locale: .current, arguments: [count] as [CVarArg])
        let formattedPrice = String(format: "%.2f", price).replacingOccurrences(of: ".", with: ",")
        let priceFormat = String(localized: "cart.format.priceEth", defaultValue: "%@ ETH")
        priceLabel.text = String(format: priceFormat, locale: .current, arguments: [formattedPrice] as [CVarArg])
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
