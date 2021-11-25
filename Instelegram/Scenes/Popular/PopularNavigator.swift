import UIKit

protocol PopularNavigatorType {
    func toSearch(userId: String)
    func toPost(postId: String, currentUserId: String)
}

struct PopularNavigator: PopularNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toSearch(userId: String) {
        let viewController = SearchViewController.instantiate()
        let navigator = SearchNavigator(navigationController: navigationController,
                                        customTabbar: customTabbar,
                                        window: window)
        let useCase = SearchUseCase()
        let viewModel = SearchViewModel(navigator: navigator, useCase: useCase,
                                        userId: userId)
        viewController.bindViewModel(to: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toPost(postId: String, currentUserId: String) {
        let viewController = PostViewController.instantiate()
        let useCase = PostUseCase()
        let navigator = PostNavigator(navigationController: navigationController,
                                      customTabbar: customTabbar, window: window)
        let viewModel = PostViewModel(useCase: useCase, navigator: navigator,
                                      currentUserId: currentUserId, postId: postId)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
