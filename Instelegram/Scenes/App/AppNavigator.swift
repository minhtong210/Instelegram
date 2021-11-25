import Foundation
import UIKit

protocol AppNavigatorType {
    func toMain()
}

struct AppNavigator: AppNavigatorType {
    unowned let window: UIWindow!
    
    func toMain() {
        let currentUser = FBaseAuth.share.getCurrentUser()
        if !currentUser.userId.isEmpty {
            let viewController = MainViewController.instantiate()
            let navigator = MainNavigator(window: window)
            let viewModel = MainViewModel(navigator: navigator, userId:  currentUser.userId)
            viewController.bindViewModel(to: viewModel)
            window.rootViewController = viewController
        } else {
            let navigation = UINavigationController()
            let viewController = LoginViewController.instantiate()
            let navigator = LoginNavigator(navigationController: navigation,
                                           window: window)
            let useCase = LoginUseCase()
            let viewModel = LoginViewModel(useCase: useCase, navigator: navigator)
            viewController.bindViewModel(to: viewModel)

            navigation.viewControllers = [viewController]
            navigation.navigationBar.isHidden = true

            window.rootViewController = navigation
        }
        window.makeKeyAndVisible()
    }
}
