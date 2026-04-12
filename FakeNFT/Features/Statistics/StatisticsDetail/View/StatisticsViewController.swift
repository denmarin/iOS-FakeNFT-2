//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.register(StatisticUserCell.self, forCellReuseIdentifier: StatisticUserCell.reuseIdentifier)
        
        return table
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
            label.text = "Нет данных"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.isHidden = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }()
    private lazy var sortButton: UIButton = {
        let sortButton = UIButton()
        sortButton.setImage(.sort, for: .normal)
        sortButton.tintColor = .ypBlack
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        return sortButton
    }()

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        tableView.dataSource = self
        tableView.delegate = self
        
        setupConstraints()
        bindViewModel()
        
        viewModel.onErrorShowAlert = { [weak self] in
            self?.showErrorAlert()
        }
        
        Task {
            await viewModel.loadUsers()
        }
    }

    private func setupConstraints() {
        setupNavigationBar()
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        view.addSubview(emptyLabel)
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        let byRating = UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.viewModel.sortUsers(by: .byRating)
        }
  
        let byName = UIAlertAction(title: "По имени", style: .default) { [weak self] _ in
            self?.viewModel.sortUsers(by: .byName)
        }
        let cancelButton = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        
        alert.addAction(byRating)
        alert.addAction(byName)
        alert.addAction(cancelButton)

        present(alert, animated: true)
        
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Не удалось получить данные",
            message: nil,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            
            Task {
                await self?.viewModel.loadUsers()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true, completion: nil)
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
        
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for state: State) {
        print("🔄 UI State: \(state)")
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
            emptyLabel.isHidden = true
            
        case .content:
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            errorLabel.isHidden = true
            emptyLabel.isHidden = true
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
            emptyLabel.isHidden = true
            
        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
            emptyLabel.isHidden = false
        }

    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticUserCell.reuseIdentifier,
            for: indexPath) as? StatisticUserCell
        else {
            return UITableViewCell()
        }
        
        let user = viewModel.users[indexPath.row]
        
        cell.configure(with: user)
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profile = viewModel.users[indexPath.row]
        
        let detailViewModel = ProfileDetailViewModel(profile: profile.toProfile(), currentUserId: RequestConstants.token)
        
        let nftService =  StatisticsService(networkClient: DefaultNetworkClient())
        
        let detailViewController = ProfileDetailViewController(
            viewModel: detailViewModel,
            nftService: nftService
        )
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
