//
//  WebViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import UIKit
import WebKit

final class WebStatisticViewController: UIViewController {
    
    private let viewModel: WebViewModelProtocol
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    init(viewModel: WebViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadWebsite()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(webView)
        
        let backButton = UIBarButtonItem(
            image: UIImage(
                systemName: "chevron.left")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
                .withTintColor(.black, renderingMode: .alwaysOriginal
                              ),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        (viewModel as? WebStatisticViewModel)?.onClose = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func loadWebsite() {
        let request = URLRequest(url: viewModel.url)
        webView.load(request)
    }
    
    @objc private func backTapped() {
        viewModel.close()
    }
}
