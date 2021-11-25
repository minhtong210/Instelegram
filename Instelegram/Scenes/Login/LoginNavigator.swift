import UIKit

protocol LoginNavigatorType {
    func toMain()
    func toSignUp()
}

struct LoginNavigator: LoginNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let window: UIWindow
    
    func toMain() {
        let userId = FBaseAuth.share.getCurrentUser().userId
        let viewController = MainViewController.instantiate()
        let navigator = MainNavigator(window: window)
        let viewModel = MainViewModel(navigator: navigator, userId: userId)
        viewController.bindViewModel(to: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func toSignUp() {
        let viewController = SignUpViewController.instantiate()
        let navigator = SignUpNavigator(navigationController: navigationController,
                                        window: window)
        let useCase = SignUpUseCase()
        let viewModel = SignUpViewModel(useCase: useCase, navigator: navigator)
        viewController.bindViewModel(to: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
