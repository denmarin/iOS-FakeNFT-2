import UIKit
import Kingfisher

final class DeleteNftViewController: UIViewController {
    // MARK: - Private Properties
    private let viewModel: DeleteNftViewModel
    
    private lazy var deleteNftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы уверены, что хотите удалить объект из корзины?"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(resource: .redUniversal), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [deleteButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    init(viewModel: DeleteNftViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurBackground()
        setupLayout()
        
        if let url = viewModel.nftImage {
            deleteNftImageView.kf.setImage(with: url)
        }
    }
    
    // MARK: - Private Methods
    private func setupBlurBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
    }
    
    private func setupLayout() {
        [deleteNftImageView, messageLabel, buttonsStackView].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            deleteNftImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteNftImageView.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -12),
            deleteNftImageView.widthAnchor.constraint(equalToConstant: 108),
            deleteNftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: 180),
            
            buttonsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalToConstant: 262),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - @objc Methods
    @objc private func didTapDelete() {
        dismiss(animated: true) { [weak self] in
            self?.viewModel.confirmDelete()
        }
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true) { [weak self] in
            self?.viewModel.cancelDelete()
        }
    }
}
