//
//  StatisticUserCell.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//
import UIKit
import Kingfisher

class StatisticUserCell: UITableViewCell {
    static let reuseIdentifier = "StatisticUserCell"
    
    private lazy var viewContent: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.blue.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 14
        image.layer.masksToBounds = true
        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupView()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    private func setupView() {
        contentView.addSubview(ratingLabel)
        contentView.addSubview(viewContent)
        viewContent.addSubview(avatarImageView)
        viewContent.addSubview(nameLabel)
        viewContent.addSubview(scoreLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        NSLayoutConstraint.activate([
            ratingLabel.heightAnchor.constraint(equalToConstant: 20),
            ratingLabel.widthAnchor.constraint(equalToConstant: 27),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            viewContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35),
            viewContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewContent.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            viewContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: viewContent.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: viewContent.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: viewContent.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            scoreLabel.trailingAnchor.constraint(equalTo: viewContent.trailingAnchor, constant: -16),
            scoreLabel.centerYAnchor.constraint(equalTo: viewContent.centerYAnchor),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user: UserListResponse) {
        ratingLabel.text = "\(String(describing: user.rating))"
        nameLabel.text = "\(user.name)"
        
        let nftsCount = user.nfts?.count ?? 0
        scoreLabel.text = "\(nftsCount)"
        
        if let avatarString = user.avatar {
            avatarImageView.kf.setImage(with: avatarString)
        } else {
            avatarImageView.image = UIImage.profileTabBar 
        }
    }
    
    private func loadAvatar(with url: URL?) {
        guard let url else {
            avatarImageView.image = UIImage.profileTabBar
            return
        }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage.profileTabBar,
            options: [.transition(.fade(0.2))])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ratingLabel.text = nil
        nameLabel.text = nil
        scoreLabel.text = nil
        avatarImageView.image = nil
        avatarImageView.kf.cancelDownloadTask()
    }
}



