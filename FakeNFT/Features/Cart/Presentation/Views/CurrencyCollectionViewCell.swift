import UIKit
import Kingfisher

final class CurrencyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrencyCollectionViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .blackUniversal
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .greenUniversal
        return label
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupViews() {
        contentView.backgroundColor = .ypLightGrey
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.ypBlack.cgColor
        
        [iconImageView, labelsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(codeLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            
            labelsStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with currency: Currency) {
        titleLabel.text = currency.title
        codeLabel.text = currency.name
        iconImageView.kf.setImage(with: URL(string: currency.image))
    }
    
    func setSelected(_ isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 1 : 0
    }
}
