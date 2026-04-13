import UIKit
import Kingfisher

final class MyNFTTableViewCell: UITableViewCell, ReuseIdentifying{
    private let NFTImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 108).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 108).isActive = true
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .favoriteImageOff), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
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
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 1
        return label
    }()
    
    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 1
        label.text = "Цена"
        return label
    }()
    
    private let priceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bodyBold
        label.textColor = .ypBlack
        label.numberOfLines = 1
        return label
    }()
    
    private let starStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        authorLabel.text = nil
        priceValueLabel.text = nil
        
        starStack.arrangedSubviews.forEach {
            starStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        likeButton.setImage(UIImage(resource: .favoriteImageOff), for: .normal)
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
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, starStack, authorLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4
        
        let priceStack = UIStackView(arrangedSubviews: [priceTitleLabel, priceValueLabel])
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.axis = .vertical
        priceStack.spacing = 2
        
        contentView.addSubview(nftView)
        contentView.addSubview(infoStack)
        contentView.addSubview(priceStack)
        
        NSLayoutConstraint.activate([
            nftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nftView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nftView.widthAnchor.constraint(equalToConstant: 108),
            nftView.heightAnchor.constraint(equalToConstant: 108),
            
            infoStack.leadingAnchor.constraint(equalTo: nftView.trailingAnchor, constant: 20),
            infoStack.centerYAnchor.constraint(equalTo: nftView.centerYAnchor),
            
            priceStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -39),
            priceStack.centerYAnchor.constraint(equalTo: nftView.centerYAnchor),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: priceStack.leadingAnchor, constant: -8)
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
    
    func config(nftImage: URL?, nftTitle: String, rating: Int, author: String, price: Double){
        NFTImageView.kf.cancelDownloadTask()
        NFTImageView.image = nil
        if let url = nftImage {
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
        authorLabel.text = "от \(author)"
        priceValueLabel.text = "\(price) ETH"
    }
}
