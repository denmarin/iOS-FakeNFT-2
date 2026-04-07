import UIKit

final class CartViewController: UIViewController {
    // MARK: - Private Properties
    private let viewModel: CartViewModel
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 140
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.allowsSelection = false
        table.dataSource = self
        table.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        return table
    }()
    
    private lazy var bottomView: CartBottomView = {
        let view = CartBottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        bottomView.alpha = 0
        
        setupNavBar()
        setupLayout()
        bindViewModel()
        
        viewModel.loadData()
    }
    
    // MARK: - Private Methods
    private func setupNavBar() {
        let filterButton = UIBarButtonItem(
            image: UIImage(resource: .sort),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        filterButton.tintColor = UIColor(resource: .ypBlack).withAlphaComponent(0)
        filterButton.isEnabled = false
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.bottomView.configure(
                count: self.viewModel.totalAmount,
                price: self.viewModel.totalPrice
            )
            
            UIView.animate(withDuration: 0.3) {
                self.bottomView.alpha = 1
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        viewModel.onLoadingChange = { isLoading in
            if isLoading {
                UIBlockingProgressHUD.show()
            } else {
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    // MARK: - @objc Methods
    @objc private func filterButtonTapped() {
        // TODO: Process code
    }
}

// MARK: - Extensions
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartTableViewCell.identifier,
            for: indexPath
        ) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let nft = viewModel.items[indexPath.row]
        cell.configure(with: nft)
        cell.delegate = self
        return cell
    }
}

extension CartViewController: CartTableViewCellDelegate {
    func didTapDeleteButton(on cell: CartTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let nft = viewModel.items[indexPath.row]
        
        showDeleteConfirmation(for: nft)
    }
    
    private func showDeleteConfirmation(for nft: Nft) {
        let deleteVC = DeleteNftViewController(nftImage: nft.images.first)
        deleteVC.modalPresentationStyle = .overFullScreen
        deleteVC.modalTransitionStyle = .crossDissolve
        
        deleteVC.completion = { [weak self] confirmed in
            if confirmed {
                self?.viewModel.removeNft(nft)
            }
        }
        
        present(deleteVC, animated: true)
    }
}
