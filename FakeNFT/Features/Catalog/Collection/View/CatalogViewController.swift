import UIKit

final class CatalogViewController: UIViewController {

    private enum Constants {
        static let emptyMessage = "Коллекции пока отсутствуют"
    }

    private let viewModel: CatalogViewModel
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var cellModels: [CatalogCollectionCellViewModel] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CatalogCollectionCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 188
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
        return tableView
    }()

    private let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = CatalogColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Error.repeat", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()

    private lazy var stateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stateMessageLabel, retryButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.isHidden = true
        return stack
    }()

    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupLayout()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    @objc
    private func didTapSort() {
        viewModel.didTapSort()
    }

    @objc
    private func didTapRetry() {
        viewModel.retryLoading()
    }

    private func setupLayout() {
        view.backgroundColor = CatalogColors.screenBackground
        navigationItem.title = nil

        let sortItem = UIBarButtonItem(
            image: UIImage(resource: .sort),
            style: .plain,
            target: self,
            action: #selector(didTapSort)
        )
        sortItem.tintColor = CatalogColors.textPrimary
        navigationItem.rightBarButtonItem = sortItem

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)

        view.addSubview(stateStackView)
        stateStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stateStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.onPresentSortOptions = { [weak self] options in
            self?.showSortOptions(options: options)
        }
    }

    private func render(_ state: CatalogViewState) {
        switch state {
        case .loading:
            setSortEnabled(false)
            hideState()
            tableView.isHidden = true
            showLoading()

        case .content(let models):
            setSortEnabled(true)
            hideLoading()
            hideState()
            tableView.isHidden = false
            cellModels = models
            tableView.reloadData()

        case .empty:
            setSortEnabled(false)
            hideLoading()
            tableView.isHidden = true
            showState(message: Constants.emptyMessage, showsRetry: false)

        case .error(let message):
            setSortEnabled(false)
            hideLoading()
            tableView.isHidden = true
            showState(message: message, showsRetry: true)
        }
    }

    private func showState(message: String, showsRetry: Bool) {
        stateMessageLabel.text = message
        retryButton.isHidden = !showsRetry
        stateStackView.isHidden = false
    }

    private func hideState() {
        stateStackView.isHidden = true
        stateMessageLabel.text = nil
        retryButton.isHidden = true
    }

    private func setSortEnabled(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }

    private func showSortOptions(options: [CatalogSortOption]) {
        let alert = UIAlertController(
            title: "Сортировка",
            message: nil,
            preferredStyle: .actionSheet
        )

        options.forEach { option in
            let action = UIAlertAction(title: option.displayTitle, style: .default) { [weak self] _ in
                self?.viewModel.didSelectSortOption(option)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.maxY,
                width: 1,
                height: 1
            )
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
}

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogCollectionCell = tableView.dequeueReusableCell()
        let model = cellModels[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectCollection(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

extension CatalogViewController: LoadingView {}
