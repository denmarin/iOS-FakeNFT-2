//
//  NFTCollectionCell.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 01.04.2026.
//

import UIKit
import Kingfisher

final class NftCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NftCollectionCell"
    
    var onLikeTap: ((String) -> Void)?
    var onCartTap: ((String) -> Void)?
    private var currentNftId: String?
    
    private lazy var viewStack: UIView = {
        let stack = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        image.backgroundColor = .ypLightGrey
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var ratingView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .left
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .left
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(.favoriteImageOff, for: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cartButton: UIButton = {
        let button =  UIButton()
        button.setImage(.cartTabBar, for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.addSubview(imageView)
        contentView.addSubview(viewStack)
        contentView.addSubview(likeButton)
        contentView.addSubview(ratingView)
        contentView.addSubview(cartButton)
        
        viewStack.addSubview(nameLabel)
        viewStack.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 108),
            imageView.widthAnchor.constraint(equalToConstant: 108)
        ])
        
        NSLayoutConstraint.activate([
            ratingView.heightAnchor.constraint(equalToConstant: 12),
            ratingView.widthAnchor.constraint(equalToConstant: 68),
            ratingView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            viewStack.topAnchor.constraint(equalTo: ratingView.bottomAnchor),
            viewStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewStack.widthAnchor.constraint(equalToConstant: 68)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: viewStack.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 68)

        ])
        
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: viewStack.leadingAnchor),
            priceLabel.widthAnchor.constraint(equalToConstant: 68)
        ])
     
        NSLayoutConstraint.activate([
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.topAnchor.constraint(equalTo: viewStack.topAnchor),
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            cartButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }
    
    func configure(with nft: Nft, isLiked: Bool, isInCart: Bool) {
        currentNftId = nft.id
        nameLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        
        setupRating(rating: nft.rating)
        
        if let firstImageUrl = nft.images.first {
            imageView.kf.setImage(
                with: firstImageUrl,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        if isLiked {
            likeButton.setImage(UIImage.favoriteImageOn, for: .normal)
        } else {
            likeButton.setImage(.favoriteImageOff, for: .normal)
            likeButton.tintColor = .gray
        }
        if isInCart {
            cartButton.setImage(UIImage.cartTabBar, for: .normal) 
            cartButton.tintColor = .systemBlue
        } else {
            cartButton.setImage(UIImage.cartImageAdd, for: .normal)
            cartButton.tintColor = .ypBlack
        }
        
        currentNftId = nft.id
    }
    
    private func setupRating(rating: Int) {
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
         
        for index in 1...5 {
            let starImage: UIImage?
            if index <= rating {
                starImage = UIImage.startImageOn
            } else {
                starImage = UIImage.startImageOff
            }
            
            let imageView = UIImageView()
            imageView.image = starImage
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            ratingView.addArrangedSubview(imageView)
        }
    }
    
    @objc private func likeButtonTapped() {
        print("Нажата кнопка лайка")
        guard let id = currentNftId else { return }
        onLikeTap?(id)
    }
    
    @objc private func cartButtonTapped() {
        print("Нажата кнопка корзины")
        guard let id = currentNftId else { return }
        onCartTap?(id)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        priceLabel.text = nil
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
        
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        currentNftId = nil
        onLikeTap = nil
        onCartTap = nil
    }
    
}
