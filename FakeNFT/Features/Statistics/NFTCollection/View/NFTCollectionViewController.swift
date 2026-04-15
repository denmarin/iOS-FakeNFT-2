//
//  NFTCollectionViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 01.04.2026.
//

import UIKit
import Combine

final class NftCollectionViewController: UIViewController {
    
    private let viewModel: NftCollectionViewModelProtocol
    private var stateBindingTask: Task<Void, Never>?
    private var nftsBindingTask: Task<Void, Never>?
    
    private var hasShownErrorAlert = false
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            NftCollectionCell.self,
            forCellWithReuseIdentifier: NftCollectionCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .redUniversal
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("No NFT", comment: "")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ypLightGrey
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: NftCollectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stateBindingTask?.cancel()
        nftsBindingTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViewLayout()
        setupConstraints()
        bindViewModel()
 
        Task {
            await viewModel.loadNfts()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("Collection NFT", comment: "")

        let backButton = UIBarButtonItem(
            image: UIImage(resource: .backButtonDark),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical

            layout.minimumLineSpacing = 16

            layout.minimumInteritemSpacing = 9

            let horizontalInsets: CGFloat = 16
            layout.sectionInset = UIEdgeInsets(
                top: 0,
                left: horizontalInsets,
                bottom: 0,
                right: horizontalInsets
            )

            let screenWidth = UIScreen.main.bounds.width
            let columnsCount: CGFloat = 3
            let interitemSpacing = layout.minimumInteritemSpacing
            let totalInteritemSpacing = interitemSpacing * (columnsCount - 1)
            let totalHorizontalInsets = horizontalInsets * 2
            
            let itemWidth = (screenWidth - totalHorizontalInsets - totalInteritemSpacing) / columnsCount
            let itemHeight = itemWidth + 50
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)

            collectionView.collectionViewLayout = layout
        }
    
    private func setupConstraints() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Couldn't get the data", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let retryAction = UIAlertAction(title: NSLocalizedString("Repeat", comment: ""), style: .default) { [weak self] _ in
            self?.hasShownErrorAlert = false
            
            Task {
                await self?.viewModel.loadNfts()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func bindViewModel() {
        stateBindingTask?.cancel()
        nftsBindingTask?.cancel()

        let statePublisher = viewModel.statePublisher
        stateBindingTask = Task { @MainActor [weak self] in
            for await state in statePublisher.values {
                guard let self else { return }
                updateUI(for: state)
                if case .error = state {
                    if hasShownErrorAlert == false {
                        hasShownErrorAlert = true
                        showErrorAlert()
                    }
                } else {
                    hasShownErrorAlert = false
                }
            }
        }

        let nftsPublisher = viewModel.nftsPublisher
        nftsBindingTask = Task { @MainActor [weak self] in
            for await _ in nftsPublisher.values {
                guard let self else { return }
                collectionView.reloadData()
            }
        }
    }
    
    private func updateUI(for state: NftCollectionState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            collectionView.isHidden = true
            errorLabel.isHidden = true
            emptyLabel.isHidden = true
            
        case .content:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = false
            errorLabel.isHidden = true
            emptyLabel.isHidden = true
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
            emptyLabel.isHidden = true
            
        case .empty:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
            errorLabel.isHidden = true
            emptyLabel.isHidden = false
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension NftCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NftCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? NftCollectionCell else {
            return UICollectionViewCell()
        }
        
        let nft = viewModel.nfts[indexPath.row]
        
        let isLiked = viewModel.isLiked(nftId: nft.id)
        let isInCart = viewModel.isInCart(nftId: nft.id)
        
        cell.configure(with: nft, isLiked: isLiked, isInCart: isInCart)
        
        cell.onLikeTap = { [weak self] nftId in
            Task {
                await self?.viewModel.toggleLike(for: nftId)
            }
        }
        cell.onCartTap = { [weak self] nftId in
            Task {
                await self?.viewModel.toggleCart(for: nftId)
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NftCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
