import UIKit

protocol SearchNavigatorType {
    func toBackView()
    func toAccount(userId: String)
}

struct SearchNavigator: SearchNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toBackView() {
        navigationController.popViewController(animated: true)
    }

    func toAccount(userId: String) {
        let viewController = AccountViewController.instantiate()
        let navigator = AccountNavigator(navigationController: navigationController,
                                         customTabbar: customTabbar,
                                         window: window)
        let useCase = AccountUseCase()
        let viewModel = AccountViewModel(useCase: useCase, navigator: navigator,
                                         userId: userId)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
