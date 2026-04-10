import UIKit

final class FavoriteNFTCollectionViewCell: UICollectionViewCell, ReuseIdentifying{
    var onLikeTapped: (() -> Void)?
    
    private let NFTImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .favoriteImageOn), for: .normal)
        button.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bodyBold
        label.textColor = .ypBlack
        label.numberOfLines = 1
        return label
    }()
    
    private let priceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption1
        label.textColor = .ypBlack
        label.numberOfLines = 1
        return label
    }()
    
    private let starStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NFTImageView.kf.cancelDownloadTask()
        NFTImageView.image = nil
        
        titleLabel.text = nil
        priceValueLabel.text = nil
        
        onLikeTapped = nil
        
        starStack.arrangedSubviews.forEach {
            starStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    private func setupUI(){
        let nftView = UIView()
        nftView.translatesAutoresizingMaskIntoConstraints = false
        nftView.addSubview(NFTImageView)
        nftView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            NFTImageView.topAnchor.constraint(equalTo: nftView.topAnchor),
            NFTImageView.leadingAnchor.constraint(equalTo: nftView.leadingAnchor),
            NFTImageView.bottomAnchor.constraint(equalTo: nftView.bottomAnchor),
            NFTImageView.trailingAnchor.constraint(equalTo: nftView.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: NFTImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: NFTImageView.trailingAnchor)
        ])
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, starStack, priceValueLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4
        infoStack.setCustomSpacing(8, after: starStack)
        
        let mainStack = UIStackView(arrangedSubviews: [nftView, infoStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func updateStarStack(rating: Int){
        starStack.arrangedSubviews.forEach {
            starStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            
            if i <= rating{
                starImageView.image = UIImage(resource: .startImageOn)
            } else {
                starImageView.image = UIImage(resource: .startImageOff)
            }
            
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            
            starStack.addArrangedSubview(starImageView)
        }
    }
    
    func config(image: URL?, nftTitle: String, rating: Int, price: Double){
        NFTImageView.kf.cancelDownloadTask()
        NFTImageView.image = nil
        if let url = image{
            NFTImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2))
                ]
            )
        }
        titleLabel.text = nftTitle
        updateStarStack(rating: rating)
        priceValueLabel.text = "\(price) ETH"
    }
    
    @objc private func likeButtonDidTap(){
        onLikeTapped?()
    }
}
