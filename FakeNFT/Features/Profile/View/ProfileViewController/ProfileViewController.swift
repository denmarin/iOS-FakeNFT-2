import UIKit
import Combine
import Kingfisher

enum ProfileRow: Int, CaseIterable {
    case myNfts = 0
    case favorites
    
    var title: String {
        switch self {
        case .myNfts: return "Мои NFT"
        case .favorites: return "Избранные NFT"
        }
    }
}

final class ProfileViewController: UIViewController, LoadingView, ErrorView{
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.image = UIImage(resource: .profileImagePlaceholder)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline3
        label.textColor = .ypBlack
        label.numberOfLines = 1
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 0
        
        return label
    }()
    
    private let webSiteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption1
        label.textColor = .blueUniversal
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let profileTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 54
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.preservesSuperviewLayoutMargins = true
        table.register(ProfileTableViewCell.self)
        table.separatorStyle = .none
        table.allowsSelection = true
        return table
    }()
    
    private let nameAndImageStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()
    
    private let  descriptionAndSiteStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    private let viewModel: ProfileViewModel
    private var currentData: ProfileScreenData?
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onAppear()
    }
    
    private func setupUI(){
        setupWebSiteLabel()
        profileTable.delegate = self
        profileTable.dataSource = self
        
        let editNavBarButton = UIBarButtonItem(image: UIImage(resource: .edit), style: .plain, target: self, action: #selector(showEditProfileViewController))
        self.navigationItem.rightBarButtonItem = editNavBarButton
        
        nameAndImageStack.addArrangedSubview(profileImageView)
        nameAndImageStack.addArrangedSubview(nameLabel)
        view.addSubview(nameAndImageStack)
        
        NSLayoutConstraint.activate([
            nameAndImageStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameAndImageStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameAndImageStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        descriptionAndSiteStack.addArrangedSubview(descriptionLabel)
        descriptionAndSiteStack.addArrangedSubview(webSiteLabel)
        view.addSubview(descriptionAndSiteStack)
        
        NSLayoutConstraint.activate([
            descriptionAndSiteStack.topAnchor.constraint(equalTo: nameAndImageStack.bottomAnchor, constant: 20),
            descriptionAndSiteStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionAndSiteStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(profileTable)
        
        NSLayoutConstraint.activate([
            profileTable.topAnchor.constraint(equalTo: descriptionAndSiteStack.bottomAnchor, constant: 40),
            profileTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            profileTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            profileTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupWebSiteLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapWebsite))
        webSiteLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapWebsite() {
        viewModel.didTapWebsite()
    }
    
    private func setupBindings() {
        Task { [weak self] in
            guard let stateValues = self?.viewModel.state.values else { return }
            
            for await state in stateValues {
                self?.render(state)
            }
        }
        
        Task { [weak self] in
            guard let routeValues = self?.viewModel.route.values else { return }
            
            for await route in routeValues {
                self?.handleRoute(route)
            }
        }
    }
    
    private func render(_ state: ProfileViewState) {
        switch state {
        case .loading:
            showLoading()
            break
        case .content(let data):
            hideLoading()
            updateUI(with: data)
        case .error(let message):
            hideLoading()
            let errorModel = ErrorModel(
                message: message,
                actionText: "Повторить"
            ) { [weak self] in
                self?.viewModel.onAppear()
            }
            
            showError(errorModel)
        case .idle:
            hideLoading()
            break
        }
    }
    
    private func updateUI(with data: ProfileScreenData) {
        currentData = data
        
        nameLabel.text = data.header.name
        descriptionLabel.text = data.header.description
        webSiteLabel.text = data.header.website
        
        if let url = data.header.avatar {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .profileImagePlaceholder),
                options: [.transition(.fade(0.2))]
            )
        }
        profileTable.reloadData()
    }
    
    private func handleRoute(_ route: ProfileRoute) {
        switch route {
        case .editProfile(let profileScreenData):
            let service = ProfileServiceImp()
            let editVM = EditProfileViewModel(header: profileScreenData.header,provider: service,currentLikes: profileScreenData.favoritesIds) { [weak self] updatedHeader in
                self?.viewModel.updateHeader(updatedHeader)
                self?.presentedViewController?.dismiss(animated: true)
            }
            
            let editVC = EditProfileViewController(viewModel: editVM)
            let navVC = UINavigationController(rootViewController: editVC)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
            
        case .myNfts(let profileScreenData):
            let service = ProfileServiceImp()
            let myNftViewModel = MyNFTViewModel(nfts: profileScreenData.myNfts, nftsIds: profileScreenData.myNftsIds, provider: service)
            let vc = MyNFTViewController(viewModel: myNftViewModel)
            let navvc = UINavigationController(rootViewController: vc)
            navvc.modalPresentationStyle = .fullScreen
            present(navvc,animated: true)
        case .favorites(let profileScreenData):
            let service = ProfileServiceImp()
            let favoriteNftViewModel = FavoriteNFTViewModel(nftsIds: profileScreenData.favoritesIds, nftCards: profileScreenData.favorites,dataProvider: service, header: profileScreenData.header){[weak self] newFavorites, newFavoritesIds in
                self?.viewModel.updateFavorite(newFavorites,newFavoritesIds)
            }
            let vc = FavoriteNFTViewController(viewModel: favoriteNftViewModel)
            let navvc = UINavigationController(rootViewController: vc)
            navvc.modalPresentationStyle = .fullScreen
            present(navvc,animated: true)
        case .webView:
            let webViewViewModel = WebViewViewModel()
            let webVC = WebViewController(viewModel: webViewViewModel)
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    @objc private func showEditProfileViewController(){
        viewModel.didTapEdit()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(indexPath: indexPath)
        guard let row = ProfileRow(rawValue: indexPath.row) else { return cell }
        
        let count: Int
        switch row {
        case .myNfts:
            count = currentData?.myNftsIds.count ?? 0
        case .favorites:
            count = currentData?.favoritesIds.count ?? 0
        }
        cell.configure(text: row.title, nftCount: count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            viewModel.didTapMyNfts()
        } else if indexPath.row == 1{
            viewModel.didTapFavorites()
        }
    }
}
