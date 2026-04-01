import UIKit
import Kingfisher

final class CartTableViewCell: UITableViewCell, ReuseIdentifying {
    // MARK: - Static Properties
    static let identifier = "CartCell"
    
    // MARK: - Private Properties
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .ypBlack
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypBlack
        label.text = "Цена"
        return label
    }()
    
    private let priceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .ypBlack
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .cartImageDelete), for: .normal)
        button.tintColor = .ypBlack
        return button
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()
    
    private var starImageViews: [UIImageView] = []
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupStarViews()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
    }
    
    // MARK: - Public Methods
    func configure(with nft: Nft) {
        titleLabel.text = nft.name
        priceValueLabel.text = Self.priceString(from: nft.price)
        updateRating(nft.rating)
        setImage(url: nft.images.first)
    }
    
    func setImage(url: URL?) {
        //nftImageView.kf.setImage(with: url)
        nftImageView.backgroundColor = .lightGray
    }
    
    // MARK: - Private Methods
    private func setupStarViews() {
        starImageViews.forEach { $0.removeFromSuperview() }
        starImageViews.removeAll()
        
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 12),
                imageView.heightAnchor.constraint(equalToConstant: 12)
            ])
            
            ratingStackView.addArrangedSubview(imageView)
            starImageViews.append(imageView)
        }
    }
    
    private func setupLayout() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(priceStackView)
        contentView.addSubview(deleteButton)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(ratingStackView)
        
        priceStackView.addArrangedSubview(priceTitleLabel)
        priceStackView.addArrangedSubview(priceValueLabel)
        
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            infoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            infoStackView.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8),
            infoStackView.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -12),
            
            priceStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 12),
            priceStackView.leadingAnchor.constraint(equalTo: infoStackView.leadingAnchor),
            priceStackView.trailingAnchor.constraint(equalTo: infoStackView.trailingAnchor),
            priceStackView.bottomAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: -8),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func updateRating(_ rating: Int) {
        let clampedRating = max(0, min(5, rating))
        
        for (index, starView) in starImageViews.enumerated() {
            if index < clampedRating {
                starView.image = UIImage(resource: .startImageOn)
                starView.tintColor = .yellowUniversal
            } else {
                starView.image = UIImage(resource: .startImageOff)
                starView.tintColor = .ypLightGrey
            }
        }
    }
    
    private static func priceString(from price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = ","
        let value = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "\(value) ETH"
    }
}
