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
    }

    private func setupTabs() {
        let catalogController = TestCatalogViewController(servicesAssembly: servicesAssembly)
        catalogController.title = "Catalog"

        let cartController = makePlaceholderController(title: "Cart")
        let profileController = makePlaceholderController(title: "Profile")
        let statsController = makePlaceholderController(title: "Statistics")

        let catalogNavigation = UINavigationController(rootViewController: catalogController)
        let cartNavigation = UINavigationController(rootViewController: cartController)
        let profileNavigation = UINavigationController(rootViewController: profileController)
        let statsNavigation = UINavigationController(rootViewController: statsController)

        catalogNavigation.tabBarItem = UITabBarItem(title: "Catalog", image: UIImage(systemName: "square.grid.2x2"), tag: 0)
        cartNavigation.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)
        profileNavigation.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        statsNavigation.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(systemName: "chart.bar"), tag: 3)

        viewControllers = [
            catalogNavigation,
            cartNavigation,
            profileNavigation,
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
