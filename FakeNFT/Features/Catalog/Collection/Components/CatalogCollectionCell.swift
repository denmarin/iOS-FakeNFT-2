import UIKit

final class CatalogCollectionCell: UITableViewCell, ReuseIdentifying {

    private let coverView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let coverOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = CatalogColors.overlayStrong
        view.isUserInteractionEnabled = false
        return view
    }()

    private let coverImageView: TopAlignedAspectFillImageView = {
        let imageView = TopAlignedAspectFillImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var coverColorColumns: [UIView] = (0..<3).map { _ in
        UIView()
    }

    private lazy var coverColorStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: coverColorColumns)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = CatalogColors.textPrimary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = CatalogColors.textPrimary
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [nameLabel, nftCountLabel, spacer])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        nftCountLabel.text = nil
        coverImageView.image = nil
        coverImageView.isHidden = true
        coverOverlayView.backgroundColor = CatalogColors.overlayStrong
    }

    func configure(with model: CatalogCollectionCellViewModel) {
        nameLabel.text = model.name
        nftCountLabel.text = model.formattedNftCount
        if let coverImage = UIImage(named: model.coverImageName) {
            coverImageView.image = coverImage
            coverImageView.isHidden = false
            coverOverlayView.backgroundColor = CatalogColors.overlaySoft
        } else {
            coverImageView.image = nil
            coverImageView.isHidden = true
            coverOverlayView.backgroundColor = CatalogColors.overlayStrong
            CatalogColors.applyCoverPlaceholder(to: coverColorColumns, seed: model.name)
        }
    }

    private func setupLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(coverView)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coverView.heightAnchor.constraint(equalToConstant: 140)
        ])

        coverView.addSubview(coverColorStack)
        coverColorStack.constraintEdges(to: coverView)

        coverView.addSubview(coverImageView)
        coverImageView.constraintEdges(to: coverView)

        coverView.addSubview(coverOverlayView)
        coverOverlayView.constraintEdges(to: coverView)

        contentView.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: coverView.leadingAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: coverView.trailingAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

}
