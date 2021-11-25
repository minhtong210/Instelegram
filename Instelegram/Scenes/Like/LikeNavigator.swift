import UIKit

protocol LikeNavigatorType {
    func toPost(postId: String, currentUserId: String)
}

struct LikeNavigator: LikeNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toPost(postId: String, currentUserId: String) {
        let viewController = PostViewController.instantiate()
        let useCase = PostUseCase()
        let navigator = PostNavigator(navigationController: navigationController,
                                      customTabbar: customTabbar, window: window)
        let viewModel = PostViewModel(useCase: useCase, navigator: navigator,
                                      currentUserId: currentUserId, postId: postId )
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
