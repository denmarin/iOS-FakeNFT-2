import UIKit

final class CatalogViewController: UIViewController {

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
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: CatalogViewState) {
        switch state {
        case .loading:
            tableView.isHidden = true
            showLoading()
        case .content(let models):
            hideLoading()
            tableView.isHidden = false
            cellModels = models
            tableView.reloadData()
        case .presentSortOptions(let options):
            showSortOptions(options: options)
        case .failed(let message):
            hideLoading()
            tableView.isHidden = false
            let errorModel = ErrorModel(
                message: message,
                actionText: NSLocalizedString("Error.repeat", comment: "")
            ) { [weak self] in
                self?.viewModel.viewDidLoad()
            }
            showError(errorModel)
        }
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

extension CatalogViewController: LoadingView, ErrorView {}
