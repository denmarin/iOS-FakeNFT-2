import UIKit
import Kingfisher

final class FavoriteNFTViewController: UIViewController, LoadingView, ErrorView{
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var favoriteNFTCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .ypWhite
        
        collectionView.allowsSelection = false
        
        collectionView.register(FavoriteNFTCollectionViewCell.self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let noNFTLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = .bodyBold
        label.text = String(localized: "FavoriteNFT.noNFTLabel.text", defaultValue: "У Вас ещё нет избрианных NFT")
        return label
    }()
    
    private var viewModel: FavoriteNFTViewModel
    
    init (viewModel: FavoriteNFTViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nftArr: [NftCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupBindings()
        setupNavigationBar()
        setupUI()
        Task { [weak self] in
            await self?.viewModel.loadData()
        }
    }
    
    private func setupBindings() {
        Task { [weak self] in
            guard let states = self?.viewModel.$state.values else { return }
            for await state in states {
                self?.render(state)
            }
        }
    }
    
    private func render(_ state: FavoriteNftViewState) {
        switch state {
        case .loading:
            showLoading()
            favoriteNFTCollectionView.isHidden = true
            noNFTLabel.isHidden = true
        case .content(let nfts):
            hideLoading()
            favoriteNFTCollectionView.isHidden = false
            noNFTLabel.isHidden = true
            self.nftArr = nfts
            favoriteNFTCollectionView.reloadData()
        case .empty:
            hideLoading()
            favoriteNFTCollectionView.isHidden = true
            noNFTLabel.isHidden = false
            showEmptyState()
        case .error(let message):
            hideLoading()
            let errorModel = ErrorModel(
                message: message,
                actionText: String(localized: "Error.repeat")
            ) { [weak self] in
                Task{
                    await self?.viewModel.loadData()
                }
            }
            
            showError(errorModel)
        }
    }
    
    private func showEmptyState(){
        self.title = ""
    }
    
    private func setupNavigationBar(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.bodyBold
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        self.title = String(localized: "FavoriteNFT.navigationBar.text", defaultValue: "Избранные NFT")
        
        let backNavBarButton = UIBarButtonItem(image: UIImage(resource: .backButtonDark), style: .plain, target: self, action: #selector(dismissViewController))
        self.navigationItem.leftBarButtonItem = backNavBarButton
    }
    
    private func setupUI(){
        view.addSubview(favoriteNFTCollectionView)
        view.addSubview(noNFTLabel)
        view.addSubview(activityIndicator)
        
        activityIndicator.constraintCenters(to: view)
        noNFTLabel.constraintCenters(to: view)
        
        NSLayoutConstraint.activate([
            favoriteNFTCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            favoriteNFTCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoriteNFTCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoriteNFTCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .flexible(7)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        section.interGroupSpacing = 20
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc private func dismissViewController(){
        dismiss(animated: true)
    }
}

extension FavoriteNFTViewController: UICollectionViewDelegate{
    
}

extension FavoriteNFTViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nftArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavoriteNFTCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        let nft = nftArr[indexPath.row]
        
        cell.config(image: nft.image, nftTitle: nft.title, rating: nft.rating, price: nft.price)
        
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            self.viewModel.didTapLikeButton(nftId: nft.id)
        }
        return cell
    }
}
