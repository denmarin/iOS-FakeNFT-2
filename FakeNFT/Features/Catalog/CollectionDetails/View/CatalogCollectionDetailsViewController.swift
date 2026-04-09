import UIKit
import Kingfisher

final class CatalogCollectionDetailsViewController: UIViewController {
    private enum Layout {
        static let coverHeight: CGFloat = 310
        static let coverBottomCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let backButtonSize: CGFloat = 42
        static let backButtonTopInset: CGFloat = 9
        static let backButtonLeadingInset: CGFloat = 9
        static let backIconPointSize: CGFloat = 18
        static let titleTopSpacing: CGFloat = 16
        static let authorTopSpacing: CGFloat = 8
        static let authorSpacing: CGFloat = 4
        static let descriptionTopSpacing: CGFloat = 8
        static let gridTopSpacing: CGFloat = 16
        static let scrollBottomInset: CGFloat = 16

        static let gridInteritemSpacing: CGFloat = 7
        static let gridLineSpacing: CGFloat = 16
        static let gridColumnCount: CGFloat = 3
        static let preferredGridItemWidth: CGFloat = 108
        static let prefetchSkipCount = 9
    }

    private enum Icons {
        static let back = "chevron.left"
    }

    private let viewModel: CatalogCollectionDetailsViewModel
    private var previousNavigationBarHidden: Bool?

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Layout.backIconPointSize,
            weight: .semibold
        )
        button.setImage(UIImage(systemName: Icons.back, withConfiguration: symbolConfiguration), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let coverView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.coverBottomCornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private let coverImageView: TopAlignedAspectFillImageView = {
        let imageView = TopAlignedAspectFillImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let coverOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = CatalogColors.overlayStrong
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var coverColorColumns: [UIView] = (0..<3).map { _ in UIView() }

    private lazy var coverColorStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: coverColorColumns)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = CatalogColors.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private let authorPrefixLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = CatalogColors.textSecondary
        label.text = "Автор коллекции:"
        return label
    }()

    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = CatalogColors.link
        return label
    }()

    private lazy var authorStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [authorPrefixLabel, authorNameLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = Layout.authorSpacing
        return stack
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = CatalogColors.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.gridInteritemSpacing
        layout.minimumLineSpacing = Layout.gridLineSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CatalogCollectionNftCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    private var collectionHeightConstraint: NSLayoutConstraint?
    private var cellModels: [CatalogCollectionNftCellViewModel] = []
    private var prefetchedImageURLs: Set<URL> = []
    private var imagePrefetchers: [UUID: ImagePrefetcher] = [:]

    init(viewModel: CatalogCollectionDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        imagePrefetchers.values.forEach { $0.stop() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        bindViewModel()
        applyHeader(viewModel.headerViewModel)
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        guard let navigationController else { return }
        previousNavigationBarHidden = navigationController.isNavigationBarHidden
        navigationController.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController, let previousNavigationBarHidden else { return }
        navigationController.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeightIfNeeded()
        updateScrollInsets()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateScrollInsets()
    }

    private func buildLayout() {
        view.backgroundColor = .segmentInactive

        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentView.addSubview(coverView)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverView.heightAnchor.constraint(equalToConstant: Layout.coverHeight)
        ])

        coverView.addSubview(coverColorStack)
        coverColorStack.constraintEdges(to: coverView)

        coverView.addSubview(coverImageView)
        coverImageView.constraintEdges(to: coverView)

        coverView.addSubview(coverOverlayView)
        coverOverlayView.constraintEdges(to: coverView)

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: Layout.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset)
        ])

        contentView.addSubview(authorStack)
        authorStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.authorTopSpacing),
            authorStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorStack.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor)
        ])

        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: authorStack.bottomAnchor, constant: Layout.descriptionTopSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        self.collectionHeightConstraint = collectionHeightConstraint
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Layout.gridTopSpacing),
            collectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            collectionHeightConstraint,
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.backButtonTopInset),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.backButtonLeadingInset),
            backButton.widthAnchor.constraint(equalToConstant: Layout.backButtonSize),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor)
        ])

        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func applyHeader(_ header: CatalogCollectionDetailsHeaderViewModel) {
        titleLabel.text = header.title
        descriptionLabel.text = header.description
        authorNameLabel.text = header.authorName

        coverImageView.kf.cancelDownloadTask()

        if let coverImage = UIImage(named: header.coverImageName) {
            coverImageView.image = coverImage
            coverImageView.isHidden = false
            coverOverlayView.backgroundColor = CatalogColors.overlaySoft
        } else if let coverURL = makeRemoteURL(from: header.coverImageName) {
            coverImageView.isHidden = false
            coverOverlayView.backgroundColor = CatalogColors.overlaySoft
            coverImageView.kf.indicatorType = .activity
            let processor = DownsamplingImageProcessor(size: resolvedCoverTargetSize())
            coverImageView.kf.setImage(
                with: coverURL,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .backgroundDecode
                ]
            )
        } else {
            coverImageView.image = nil
            coverImageView.isHidden = true
            coverOverlayView.backgroundColor = CatalogColors.overlayStrong
            CatalogColors.applyCoverPlaceholder(to: coverColorColumns, seed: header.title)
        }
    }

    private func makeRemoteURL(from source: String) -> URL? {
        guard let url = URL(string: source) else { return nil }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return nil
        }
        return url
    }

    private func render(_ state: CatalogCollectionDetailsViewState) {
        switch state {
        case .loading:
            showLoading()

        case .content(let models):
            hideLoading()
            applyContent(models)

        case .failed(let message):
            hideLoading()
            let errorModel = ErrorModel(
                message: message,
                actionText: NSLocalizedString("Error.repeat", comment: "")
            ) { [weak self] in
                self?.viewModel.retryLoading()
            }
            showError(errorModel)
        }
    }

    private func applyContent(_ models: [CatalogCollectionNftCellViewModel]) {
        let previousModels = cellModels
        cellModels = models

        guard !previousModels.isEmpty else {
            collectionView.reloadData()
            updateCollectionHeightIfNeeded()
            prefetchImages(for: models)
            return
        }

        if let insertedIndexes = insertedIndexes(from: previousModels, to: models), !insertedIndexes.isEmpty {
            let indexPaths = insertedIndexes.map { IndexPath(item: $0, section: 0) }
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: indexPaths)
            }
        } else if let changedIndexes = changedIndexes(from: previousModels, to: models), !changedIndexes.isEmpty {
            let indexPaths = changedIndexes.map { IndexPath(item: $0, section: 0) }
            collectionView.performBatchUpdates {
                collectionView.reloadItems(at: indexPaths)
            }
        } else if previousModels == models {
            // No-op update from state sync, keep current layout and cells as is.
        } else {
            collectionView.reloadData()
        }

        updateCollectionHeightIfNeeded()
        prefetchImages(for: models)
    }

    private func prefetchImages(for models: [CatalogCollectionNftCellViewModel]) {
        let urls = Set(models.dropFirst(Layout.prefetchSkipCount).compactMap(\.imageURL))
        let newURLs = urls.subtracting(prefetchedImageURLs)
        guard !newURLs.isEmpty else {
            return
        }
        prefetchedImageURLs.formUnion(newURLs)

        let prefetcherID = UUID()
        let prefetcher = ImagePrefetcher(
            urls: Array(newURLs),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .backgroundDecode
            ]
        ) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.imagePrefetchers.removeValue(forKey: prefetcherID)
            }
        }
        imagePrefetchers[prefetcherID] = prefetcher
        prefetcher.start()
    }

    private func insertedIndexes(
        from previous: [CatalogCollectionNftCellViewModel],
        to current: [CatalogCollectionNftCellViewModel]
    ) -> [Int]? {
        guard current.count > previous.count else { return nil }

        var prefixCount = 0
        while prefixCount < previous.count,
              previous[prefixCount] == current[prefixCount] {
            prefixCount += 1
        }

        var suffixCount = 0
        while suffixCount < previous.count - prefixCount,
              previous[previous.count - 1 - suffixCount] == current[current.count - 1 - suffixCount] {
            suffixCount += 1
        }

        guard prefixCount + suffixCount == previous.count else { return nil }
        return Array(prefixCount..<(current.count - suffixCount))
    }

    private func changedIndexes(
        from previous: [CatalogCollectionNftCellViewModel],
        to current: [CatalogCollectionNftCellViewModel]
    ) -> [Int]? {
        guard previous.count == current.count else { return nil }
        return previous.indices.filter { previous[$0] != current[$0] }
    }

    private func updateCollectionHeightIfNeeded() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        guard abs((collectionHeightConstraint?.constant ?? 0) - contentHeight) > 0.5 else { return }
        collectionHeightConstraint?.constant = contentHeight
        view.layoutIfNeeded()
    }

    private func updateScrollInsets() {
        let tabBarHeight = tabBarController?.tabBar.isHidden == false
            ? (tabBarController?.tabBar.frame.height ?? 0)
            : 0
        let bottomOverlayHeight = max(view.safeAreaInsets.bottom, tabBarHeight)

        var contentInset = scrollView.contentInset
        contentInset.bottom = bottomOverlayHeight + Layout.scrollBottomInset
        scrollView.contentInset = contentInset

        var indicatorInsets = scrollView.verticalScrollIndicatorInsets
        indicatorInsets.bottom = bottomOverlayHeight
        scrollView.verticalScrollIndicatorInsets = indicatorInsets
    }

    private func resolvedCoverTargetSize() -> CGSize {
        let size = coverView.bounds.size
        guard size.width > 0, size.height > 0 else {
            return CGSize(width: UIScreen.main.bounds.width, height: Layout.coverHeight)
        }
        return size
    }

    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension CatalogCollectionDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CatalogCollectionNftCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let model = cellModels[indexPath.row]
        let nftID = model.id

        cell.configure(with: model)
        cell.onFavoriteTap = { [weak self] in
            self?.viewModel.didTapFavorite(for: nftID)
        }
        cell.onCartTap = { [weak self] in
            self?.viewModel.didTapCart(for: nftID)
        }
        return cell
    }
}

extension CatalogCollectionDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Layout.gridLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Layout.gridInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = Layout.gridInteritemSpacing * (Layout.gridColumnCount - 1)
        let preferredWidth = Layout.preferredGridItemWidth
        let minimumRequiredWidth = (preferredWidth * Layout.gridColumnCount) + totalSpacing

        let width: CGFloat
        if collectionView.bounds.width >= minimumRequiredWidth {
            width = preferredWidth
        } else {
            width = floor((collectionView.bounds.width - totalSpacing) / Layout.gridColumnCount)
        }

        let height = width + CatalogCollectionNftCell.preferredAdditionalHeight
        return CGSize(width: width, height: height)
    }
}

extension CatalogCollectionDetailsViewController: LoadingView, ErrorView {}
