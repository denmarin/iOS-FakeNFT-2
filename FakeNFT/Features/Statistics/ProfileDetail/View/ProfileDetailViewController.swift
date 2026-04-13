//
//  ProfileDetailViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 30.03.2026.
//

import UIKit
import Kingfisher

final class ProfileDetailViewController: UIViewController {

    private let viewModel: ProfileDetailViewModelProtocol
    private let assembly: StatisticsAssembly

    private lazy var avatarImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 35
        image.clipsToBounds = true
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
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var  websiteButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitle("Перейти на сайт пользователя", for: .normal)
        
        button.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1.5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var  nftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(collectionNftTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let containerViewHorizontal = UIView()
    
    private lazy var nftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .ypBlack
        label.text = "Коллекция NFT"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var signImage: UIImageView = {
        let image = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        image.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        image.tintColor = .ypBlack
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
   
    
    init(viewModel: ProfileDetailViewModelProtocol, assembly: StatisticsAssembly) {
        self.viewModel = viewModel
        self.assembly = assembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        configureUI()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .ypBlack
        
        let backImage = UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
            .withTintColor(.black, renderingMode: .alwaysOriginal)

        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage

        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(websiteButton)
        view.addSubview(nftButton)
        nftButton.addSubview(nftLabel)
        nftButton.addSubview(nftCountLabel)
        nftButton.addSubview(signImage)
        
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            nftButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 41),
            nftButton.heightAnchor.constraint(equalToConstant: 54),
            nftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nftLabel.leadingAnchor.constraint(equalTo: nftButton.leadingAnchor, constant: 16),
            nftLabel.centerYAnchor.constraint(equalTo: nftButton.centerYAnchor),
            
            nftCountLabel.leadingAnchor.constraint(equalTo: nftLabel.trailingAnchor, constant: 8),
            nftCountLabel.centerYAnchor.constraint(equalTo: nftButton.centerYAnchor),

            signImage.trailingAnchor.constraint(equalTo: nftButton.trailingAnchor, constant: -16),
            signImage.centerYAnchor.constraint(equalTo: nftButton.centerYAnchor)
            
        ])
        
    }
    
    private func configureUI() {
        let profile = viewModel.profile
        
        nameLabel.text = profile.name
        nftCountLabel.text = "(\(viewModel.profile.nfts.count))"
        descriptionLabel.text = profile.description
        
        loadAvatar()
    }
    
    private func loadAvatar() {
        guard let avatarURL = viewModel.profile.avatar else {
            avatarImage.image = UIImage.profileTabBar
            return
        }
        
        avatarImage.kf.setImage(
            with: avatarURL,
            placeholder: UIImage.profileTabBar,
            options: [.transition(.fade(0.2))]
        )
    }
    
    @objc private func websiteButtonTapped() {
        guard let website = viewModel.profile.website else { return }
 
        let webVC = assembly.makeWebViewController(url: website)
 
        let navController = UINavigationController(rootViewController: webVC)

        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func collectionNftTapped() {
        
        let collectionVC = assembly.makeNftCollectionViewController(ownerProfile: viewModel.profile)
        
        navigationController?.pushViewController(collectionVC, animated: true)
    }
}
