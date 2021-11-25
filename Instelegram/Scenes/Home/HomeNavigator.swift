import UIKit

protocol HomeNavigatorType {
    func toChatList()
    func toComment(post: Post)
    func toAccount(userId: String)
}

struct HomeNavigator: HomeNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toChatList() {
        let viewController = ChatListViewController.instantiate()
        let useCase = ChatListUseCase()
        let navigator = ChatListNavigator(navigationController: navigationController,
                                          customTabbar: customTabbar)
        let viewModel = ChatListViewModel(useCase: useCase, navigator: navigator)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
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
}
