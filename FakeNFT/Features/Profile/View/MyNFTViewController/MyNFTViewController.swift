import UIKit

final class MyNFTViewController: UIViewController, LoadingView, ErrorView{
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let myNFTTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .ypWhite
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 140
        table.register(MyNFTTableViewCell.self)
        table.separatorStyle = .none
        return table
    }()
    
    private let noNFTLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = .bodyBold
        label.text = "У Вас ещё нет NFT"
        return label
    }()
    
    private var viewModel: MyNFTViewModel
    
    init (viewModel: MyNFTViewModel){
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
        setupNavigationBar()
        setupUI()
        setupBindings()
    }
    
    private func setupBindings() {
        Task { [weak self] in
            guard let states = self?.viewModel.$state.values else { return }
            for await state in states {
                self?.render(state)
            }
        }
    }
    
    private func render(_ state: MyNftViewState) {
        switch state {
        case .loading:
            showLoading()
            myNFTTable.isHidden = true
            noNFTLabel.isHidden = true
        case .content(let nfts):
            hideLoading()
            myNFTTable.isHidden = false
            noNFTLabel.isHidden = true
            self.nftArr = nfts
            myNFTTable.reloadData()
        case .empty:
            hideLoading()
            myNFTTable.isHidden = true
            noNFTLabel.isHidden = false
            showEmptyState()
        case .error(let message):
            hideLoading()
            let errorModel = ErrorModel(
                message: message,
                actionText: "Повторить"
            ) { [weak self] in
                self?.viewModel.loadData()
            }
            
            showError(errorModel)
        }
    }
    
    private func showEmptyState(){
        self.title = ""
        self.navigationItem.rightBarButtonItem?.isHidden = true
    }
    
    private func setupUI(){
        myNFTTable.delegate = self
        myNFTTable.dataSource = self
        view.addSubview(noNFTLabel)
        view.addSubview(myNFTTable)
        view.addSubview(activityIndicator)
        
        activityIndicator.constraintCenters(to: view)
        noNFTLabel.constraintCenters(to: view)
        
        NSLayoutConstraint.activate([
            myNFTTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            myNFTTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myNFTTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myNFTTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        
        self.title = "Мои NFT"
        
        let sortNavBarButton = UIBarButtonItem(image: UIImage(resource: .sort), style: .plain, target: self, action: #selector(didTapSortButton))
        self.navigationItem.rightBarButtonItem = sortNavBarButton
        let backNavBarButton = UIBarButtonItem(image: UIImage(resource: .backButton), style: .plain, target: self, action: #selector(dismissViewController))
        self.navigationItem.leftBarButtonItem = backNavBarButton
    }
    
    @objc private func dismissViewController(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSortButton(){
        let actionSheet = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "По цене", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .price)
        })
        actionSheet.addAction(UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .rating)
        })
        actionSheet.addAction(UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .name)
        })
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension MyNFTViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nftArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyNFTTableViewCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.config(nftImageName: nftArr[indexPath.row].imageAssetName, nftTitle: nftArr[indexPath.row].title, rating: nftArr[indexPath.row].rating, author: nftArr[indexPath.row].authorName, price: nftArr[indexPath.row].priceText)
        return cell
    }
    
    
}
