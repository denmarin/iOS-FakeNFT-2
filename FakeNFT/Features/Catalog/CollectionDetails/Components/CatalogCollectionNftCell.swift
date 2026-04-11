import UIKit
import Kingfisher

final class CatalogCollectionNftCell: UICollectionViewCell, ReuseIdentifying {
    static let preferredAdditionalHeight: CGFloat = 76

    private enum Layout {
        static let minTapArea: CGFloat = 44
        static let iconSize: CGFloat = 24
        static let imageCornerRadius: CGFloat = 12
        static let imageToRatingSpacing: CGFloat = 8
        static let ratingToNameSpacing: CGFloat = 4
        static let nameToPriceSpacing: CGFloat = 2
        static let ratingSize = CGSize(width: 64, height: 12)
        static let nameTrailingSpacing: CGFloat = 6
    }

    private static let favoriteOnIcon = resolveIcon(image: UIImage(resource: .favoriteImageOn))
    private static let favoriteOffIcon = resolveIcon(image: UIImage(resource: .favoriteImageOff))
    private static let cartAddIcon = resolveIcon(image: UIImage(resource: .cartImageAdd))
    private static let cartDeleteIcon = resolveIcon(image: UIImage(resource: .cartImageDelete))
    private static let starOnIcon = resolveIcon(image: UIImage(resource: .startImageOn))
    private static let starOffIcon = resolveIcon(image: UIImage(resource: .startImageOff))

    var onFavoriteTap: (() -> Void)?
    var onCartTap: (() -> Void)?

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = CatalogColors.imagePlaceholderBackground
        view.layer.cornerRadius = Layout.imageCornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let favoriteIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var favoriteTapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addAction(
            UIAction { [weak self] _ in
                self?.onFavoriteTap?()
            },
            for: .touchUpInside
        )
        return button
    }()

    private lazy var ratingImageViews: [UIImageView] = (0..<5).map { _ in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: ratingImageViews)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 2
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = CatalogColors.textPrimary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = CatalogColors.textPrimary
        return label
    }()

    private let cartIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var cartTapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addAction(
            UIAction { [weak self] _ in
                self?.onCartTap?()
            },
            for: .touchUpInside
        )
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        onFavoriteTap = nil
        onCartTap = nil
    }

    func configure(with model: CatalogCollectionNftCellViewModel) {
        nameLabel.text = model.name
        priceLabel.text = model.priceText
        favoriteIconView.image = model.isFavorite ? Self.favoriteOnIcon : Self.favoriteOffIcon
        cartIconView.image = model.isInCart ? Self.cartDeleteIcon : Self.cartAddIcon
        configureRating(model.rating)

        if let imageURL = model.imageURL {
            nftImageView.kf.indicatorType = .activity
            let targetSize = resolvedImageTargetSize()
            let processor = DownsamplingImageProcessor(size: targetSize)
            nftImageView.kf.setImage(
                with: imageURL,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .backgroundDecode
                ]
            )
        } else {
            nftImageView.image = nil
        }
    }

    private func configureRating(_ rawRating: Int) {
        let rating = max(0, min(rawRating, ratingImageViews.count))
        for (index, imageView) in ratingImageViews.enumerated() {
            imageView.image = index < rating ? Self.starOnIcon : Self.starOffIcon
        }
    }

    private func buildLayout() {
        contentView.backgroundColor = .clear

        contentView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainerView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor)
        ])

        imageContainerView.addSubview(nftImageView)
        nftImageView.constraintEdges(to: imageContainerView)

        imageContainerView.addSubview(favoriteIconView)
        favoriteIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteIconView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            favoriteIconView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
        ])

        imageContainerView.addSubview(favoriteTapButton)
        favoriteTapButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteTapButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            favoriteTapButton.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            favoriteTapButton.widthAnchor.constraint(equalToConstant: Layout.minTapArea),
            favoriteTapButton.heightAnchor.constraint(equalToConstant: Layout.minTapArea)
        ])
        NSLayoutConstraint.activate([
            favoriteIconView.centerXAnchor.constraint(equalTo: favoriteTapButton.centerXAnchor),
            favoriteIconView.centerYAnchor.constraint(equalTo: favoriteTapButton.centerYAnchor)
        ])

        contentView.addSubview(ratingStackView)
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: Layout.imageToRatingSpacing),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.widthAnchor.constraint(equalToConstant: Layout.ratingSize.width),
            ratingStackView.heightAnchor.constraint(equalToConstant: Layout.ratingSize.height)
        ])

        contentView.addSubview(cartIconView)
        cartIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cartIconView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            cartIconView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
        ])

        contentView.addSubview(cartTapButton)
        cartTapButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cartTapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartTapButton.centerYAnchor.constraint(equalTo: cartIconView.centerYAnchor),
            cartTapButton.widthAnchor.constraint(equalToConstant: Layout.minTapArea),
            cartTapButton.heightAnchor.constraint(equalToConstant: Layout.minTapArea)
        ])
        NSLayoutConstraint.activate([
            cartIconView.centerXAnchor.constraint(equalTo: cartTapButton.centerXAnchor),
            cartIconView.centerYAnchor.constraint(equalTo: cartTapButton.centerYAnchor)
        ])

        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: Layout.ratingToNameSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cartTapButton.leadingAnchor, constant: -Layout.nameTrailingSpacing)
        ])

        NSLayoutConstraint.activate([
            cartTapButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])

        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.nameToPriceSpacing),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private static func resolveIcon(image: UIImage) -> UIImage? {
        trimTransparentInsets(from: image)
    }

    private func resolvedImageTargetSize() -> CGSize {
        let size = imageContainerView.bounds.size
        guard size.width > 0, size.height > 0 else {
            return CGSize(width: 240, height: 240)
        }
        return size
    }

    private static func trimTransparentInsets(from image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data else {
            return image
        }

        let alphaInfo = cgImage.alphaInfo
        let alphaIndex: Int
        switch alphaInfo {
        case .premultipliedFirst, .first, .alphaOnly:
            alphaIndex = 0
        case .premultipliedLast, .last:
            alphaIndex = 3
        default:
            return image
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        guard bytesPerPixel >= 4 else { return image }

        let width = cgImage.width
        let height = cgImage.height
        let bytes = CFDataGetBytePtr(data)

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel + alphaIndex
                let alpha = bytes?[offset] ?? 0
                guard alpha > 0 else { continue }
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }

        guard maxX >= minX, maxY >= minY else { return image }

        let cropRect = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX + 1,
            height: maxY - minY + 1
        )
        guard let croppedImage = cgImage.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
