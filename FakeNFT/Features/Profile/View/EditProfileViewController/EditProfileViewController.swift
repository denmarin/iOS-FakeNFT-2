import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController,LoadingView,ErrorView{
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.image = UIImage(resource: .profileImagePlaceholder)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return imageView
    }()
    
    private let photoIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(resource: .editPhotoIcon)
        imageView.heightAnchor.constraint(equalToConstant: 22.57).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 22.57).isActive = true
        return imageView
    }()
    
    private let profilePhotoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.setTitle("Сохранить", for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let viewModel: EditProfileViewModel
    
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameFields = EditProfileFiledWithTextField(title: "Имя", text: "")
    private let descriptionFields = EditProfileFiledWithTextView(title: "Описание", text: "")
    private let siteFields = EditProfileFiledWithTextField(title: "Сайт", text: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        let backNavBarButton = UIBarButtonItem(image: UIImage(resource: .backButton), style: .plain, target: self, action: #selector(dismissViewController))
        self.navigationItem.leftBarButtonItem = backNavBarButton
        setupPhotoView()
        setupScrollViewAndContentView()
        setupBindings()
        setupUI()
        initWithViewModel()
        setupKeyboardHiding()
    }
    
    private func setupBindings() {
        
        nameFields.onTextChanged = { [weak self] newText in
            self?.viewModel.name = newText
        }
        
        descriptionFields.onTextChanged = { [weak self] newText in
            self?.viewModel.description = newText
        }
        
        siteFields.onTextChanged = { [weak self] newText in
            self?.viewModel.website = newText
        }
        
        Task { [weak self] in
            guard let changes = self?.viewModel.$isChanged.values else { return }
            for await isChanged in changes {
                self?.saveButton.isHidden = !isChanged
            }
        }
        
        Task { [weak self] in
            guard let urlStream = self?.viewModel.$avatar.values else { return }
            
            for await url in urlStream {
                self?.profileImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(resource: .profileImagePlaceholder),
                    options: [.transition(.fade(0.2))]
                )
            }
        }
        
        Task { [weak self] in
            guard let states = self?.viewModel.$state.values else { return }
            
            for await state in states {
                switch state {
                case .idle:
                    self?.hideLoading()
                    self?.saveButton.isEnabled = true
                    
                case .loading:
                    self?.showLoading()
                    self?.saveButton.isEnabled = false
                    
                case .error(let message):
                    self?.hideLoading()
                    self?.saveButton.isEnabled = true
                    let errorModel = ErrorModel(
                        message: message,
                        actionText: "Повторить"
                    ) { [weak self] in
                        self?.viewModel.didTapSave()
                    }
                    self?.showError(errorModel)
                }
            }
        }
        
    }
    
    private func initWithViewModel(){
        nameFields.textField.text = viewModel.name
        descriptionFields.textView.text = viewModel.description
        siteFields.textField.text = viewModel.website
        
        if let url = viewModel.avatar {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .profileImagePlaceholder),
                options: [.transition(.fade(0.2))]
            )
        }
    }
    
    private func setupScrollViewAndContentView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        let minHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor)
        minHeightConstraint.priority = .defaultLow
        minHeightConstraint.isActive = true
    }
    
    private func setupUI(){
        contentView.addSubview(profilePhotoView)
        contentView.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
        
        mainStackView.addArrangedSubview(nameFields)
        mainStackView.addArrangedSubview(descriptionFields)
        mainStackView.addArrangedSubview(siteFields)
        
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            profilePhotoView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            profilePhotoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -152)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupPhotoView(){
        profilePhotoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoDidTap))
        profilePhotoView.addGestureRecognizer(tapGesture)
        profilePhotoView.addSubview(profileImageView)
        profilePhotoView.addSubview(photoIconImageView)
        
        profileImageView.constraintCenters(to: profilePhotoView)
        
        NSLayoutConstraint.activate([
            profilePhotoView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            photoIconImageView.trailingAnchor.constraint(equalTo: profilePhotoView.trailingAnchor, constant: 0),
            photoIconImageView.bottomAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupKeyboardHiding() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func dismissViewController(){
        if viewModel.isChanged{
            let alert = UIAlertController(title: "Уверены, что хотите выйти?", message: nil, preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Выйти", style: .default){ [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Остаться", style: .cancel)
            alert.addAction(exitAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }else{
            dismiss(animated: true)
        }
    }
    
    @objc private func saveButtonDidTap() {
        viewModel.didTapSave()
    }
    
    @objc private func photoDidTap() {
        let actionSheet = UIAlertController(title: "Фото профиля", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Изменить фото", style: .default) { [weak self] _ in
            self?.showUrlAlert()
        }
        
        let deleteAction = UIAlertAction(title: "Удалить фото", style: .destructive) { [weak self] _ in
            self?.viewModel.removeAvatar()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func showUrlAlert() {
        let alert = UIAlertController(title: "Ссылка на фото", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Введите название URL изображения"
        }
        
        let okAction = UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                guard let url = URL(string: text) else { return }
                self?.viewModel.updateAvatar(with: url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}
