import UIKit
import RxSwift

protocol PostNavigatorType {
    func toComment(post: Post)
    func toAccount(userId: String)
    func toBackView()
}

struct PostNavigator: PostNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toComment(post: Post) {
        let viewController = CommentViewController.instantiate()
        let useCase = CommentUseCase()
        let navigator = CommentNavigator(navigationController: navigationController,
                                         customTabbar: customTabbar)
        let viewModel = CommentViewModel(useCase: useCase, navigator: navigator,
                                         post: post)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        customTabbar.isHidden = true
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
    
    func toBackView() {
        customTabbar.isHidden = false
        navigationController.popViewController(animated: true)
    }
    
}
