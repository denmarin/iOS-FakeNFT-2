import UIKit
import WebKit

final class CatalogAuthorWebViewController: UIViewController {
    private enum Layout {
        static let topBarHeight: CGFloat = 44
        static let backButtonSize: CGFloat = 44
        static let backButtonLeadingInset: CGFloat = 0
        static let backIconPointSize: CGFloat = 18
    }

    private enum Icons {
        static let back = "chevron.left"
    }

    private let url: URL
    private var previousNavigationBarHidden: Bool?

    private lazy var topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = CatalogColors.screenBackground
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Layout.backIconPointSize,
            weight: .semibold
        )
        button.setImage(UIImage(systemName: Icons.back, withConfiguration: symbolConfiguration), for: .normal)
        button.tintColor = CatalogColors.textPrimary
        button.addAction(
            UIAction { [weak self] _ in
                self?.navigateBack()
            },
            for: .touchUpInside
        )
        return button
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = CatalogColors.screenBackground
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        loadPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.title = nil

        guard let navigationController else { return }
        previousNavigationBarHidden = navigationController.isNavigationBarHidden
        navigationController.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController, let previousNavigationBarHidden else { return }
        navigationController.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
    }

    private func buildLayout() {
        view.backgroundColor = CatalogColors.screenBackground

        view.addSubview(topBarView)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: Layout.topBarHeight)
        ])

        topBarView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: Layout.backButtonLeadingInset),
            backButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: Layout.backButtonSize),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor)
        ])

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
    }

    private func loadPage() {
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension CatalogAuthorWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation?) {
        activityIndicator.startAnimating()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation?) {
        activityIndicator.stopAnimating()
    }

    func webView(_: WKWebView, didFail _: WKNavigation?, withError _: any Error) {
        activityIndicator.stopAnimating()
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation?, withError _: any Error) {
        activityIndicator.stopAnimating()
    }
}
