import UIKit

final class CartViewController: UIViewController, ErrorView {
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
    
    private lazy var  emptyCartLabel: UILabel = {
        let label = UILabel()
        label.text = "Корзина пуста"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        view.addSubview(emptyCartLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 76),
            
            emptyCartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            self.updateUI()
        }
        
        viewModel.onLoadingChange = { [weak self] isLoading in
            if isLoading {
                UIBlockingProgressHUD.show()
            } else {
                UIBlockingProgressHUD.dismiss()
                self?.updateUI()
            }
        }
        
        viewModel.onError = { [weak self] errorModel in
            self?.showError(errorModel)
        }
    }
    
    private func updateUI() {
        guard !viewModel.isLoading else { return }
        
        let isEmpty = viewModel.items.isEmpty
        
        emptyCartLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        bottomView.isHidden = isEmpty
        
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
        navigationItem.rightBarButtonItem?.tintColor = isEmpty ? .clear : UIColor(resource: .ypBlack)
        
        if !isEmpty {
            tableView.reloadData()
            bottomView.configure(
                count: viewModel.totalAmount,
                price: viewModel.totalPrice
            )
            
            UIView.animate(withDuration: 0.3) {
                self.bottomView.alpha = 1
            }
        }
    }
    
    // MARK: - @objc Methods
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(
            title: "Сортировка",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "По цене", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .price)
        })
        
        alert.addAction(UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .rating)
        })
        
        alert.addAction(UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .name)
        })
        
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
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
