import UIKit

final class PaymentMethodViewController: UIViewController {
    // MARK: - Private Properties
    private let viewModel: PaymentMethodViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 7
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CurrencyCollectionViewCell.self, forCellWithReuseIdentifier: CurrencyCollectionViewCell.reuseIdentifier)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlack
        button.setTitle(String(localized: "cart.payment.pay", defaultValue: "Оплатить"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .bodyBold
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapPay), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        return textView
    }()
    
    // MARK: - Init
    init(viewModel: PaymentMethodViewModel) {
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
        setupNavigationBar()
        setupUI()
        setupTermsText()
        bindViewModel()
        viewModel.fetchCurrencies()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        let backImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
        
        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupTermsText() {
        let fullText = String(localized: "cart.payment.termsFull", defaultValue: "Совершая покупку, вы соглашаетесь с условиями Пользовательского соглашения")
        let linkText = String(localized: "cart.payment.termsLink", defaultValue: "Пользовательского соглашения")
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.ypBlack,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        let range = (fullText as NSString).range(of: linkText)
        attributedString.addAttribute(.link, value: "https://yandex.ru/legal/practicum_termsofuse", range: range)
        attributedString.addAttribute(.font, value: UIFont.caption2, range: NSRange(location: 0, length: fullText.count))
        
        termsTextView.attributedText = attributedString
    }
    
    private func bindViewModel() {
        viewModel.onCurrenciesLoaded = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.onPaymentResult = { [weak self] isSuccess in
            if isSuccess {
                self?.showSuccess()
            } else {
                self?.showError()
            }
        }
        
        viewModel.onLoadingStateChanged = { isLoading in
            if isLoading {
                UIBlockingProgressHUD.show()
            } else {
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        title = String(localized: "cart.payment.title", defaultValue: "Выберите способ оплаты")
        
        [collectionView, bottomView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [termsTextView, payButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            termsTextView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            termsTextView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            termsTextView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            
            payButton.topAnchor.constraint(equalTo: termsTextView.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showSuccess() {
        let successVM = SuccessViewModel()
        let successVC = SuccessViewController(viewModel: successVM)
        
        successVM.onReturn = { [weak self] in
            self?.dismiss(animated: true) {
                self?.navigationController?.popToRootViewController(animated: true)
                
                if let cartVC = self?.navigationController?.viewControllers.first as? CartViewController {
                    cartVC.refreshCartData()
                }
            }
        }
        
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true)
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: String(localized: "cart.payment.alertPayFailed", defaultValue: "Не удалось произвести оплату"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "cart.payment.cancel", defaultValue: "Отмена"), style: .cancel))
        alert.addAction(UIAlertAction(title: String(localized: "cart.common.retry", defaultValue: "Повторить"), style: .default) { [weak self] _ in
            self?.viewModel.pay()
        })
        present(alert, animated: true)
    }
    
    // MARK: - @objc Methods
    @objc private func didTapPay() {
        viewModel.pay()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapTerms() {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse") else { return }
        
        let webViewModel = WebViewModel(url: url)
        let webVC = WebViewController(viewModel: webViewModel)
        
        webVC.title = ""
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - Extensions
extension PaymentMethodViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCollectionViewCell.reuseIdentifier, for: indexPath) as? CurrencyCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.currencies[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 7) / 2
        return CGSize(width: width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectCurrency(at: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? CurrencyCollectionViewCell {
            cell.setSelected(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CurrencyCollectionViewCell {
            cell.setSelected(false)
        }
    }
}

extension PaymentMethodViewController: UITextViewDelegate {
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        if case .link(let url) = textItem.content {
            return UIAction { [weak self] _ in
                let webViewModel = WebViewModel(url: url)
                let webVC = WebViewController(viewModel: webViewModel)
                self?.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        return defaultAction
    }
}
