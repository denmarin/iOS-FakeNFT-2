import UIKit

final class AppTabBarController: UITabBarController {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        self.selectedIndex = 1
    }

    private func setupTabs() {
        let catalogController = TestCatalogViewController(servicesAssembly: servicesAssembly)

        let cartController = UIViewController()
        
        let profileService = ProfileServiceImp()
        let profileViewModel = ProfileViewModelImpl(provider: profileService)
        let profileController = ProfileViewController(viewModel: profileViewModel)
        
        let statsController = UIViewController()

        let catalogNavigation = UINavigationController(rootViewController: catalogController)
        let cartNavigation = UINavigationController(rootViewController: cartController)
        let profileNavigation = UINavigationController(rootViewController: profileController)
        let statsNavigation = UINavigationController(rootViewController: statsController)

        profileNavigation.tabBarItem = UITabBarItem(title: String(localized: "profile"), image: UIImage(resource: .profileTabBar), tag: 0)
        catalogNavigation.tabBarItem = UITabBarItem(title: String(localized: "catalog"), image: UIImage(resource: .catalogTabBar), tag: 1)
        cartNavigation.tabBarItem = UITabBarItem(title: String(localized: "cart"), image: UIImage(resource: .cartTabBar), tag: 2)
        statsNavigation.tabBarItem = UITabBarItem(title: String(localized: "statistics"), image: UIImage(resource: .statisticsTabBar), tag: 3)

        viewControllers = [
            profileNavigation,
            catalogNavigation,
            cartNavigation,
            statsNavigation
        ]
    }

    private func makePlaceholderController(title: String) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = title

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .secondaryLabel
        viewController.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])

        return viewController
    }
}
