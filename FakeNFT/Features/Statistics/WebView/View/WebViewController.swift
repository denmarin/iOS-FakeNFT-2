//
//  WebViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    private let url: URL
    
    // WebView для отображения контента
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // Кнопка закрытия/назад
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebsite()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(webView)
        view.addSubview(closeButton)
        setupNavigationBar()
        
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .ypBlack
        
        let backImage = UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
            .withTintColor(.black, renderingMode: .alwaysOriginal)

        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage

        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func loadWebsite() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}
