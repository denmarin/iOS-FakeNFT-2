import UIKit
import WebKit

final class WebViewController: UIViewController {
    private let viewModel: WebViewViewModel
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .ypWhite
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    init(viewModel: WebViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        setupUI()
        loadWebView()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(resource: .backButton),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(webView)
    
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadWebView() {
        let request = URLRequest(url: viewModel.url)
        webView.load(request)
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
}
