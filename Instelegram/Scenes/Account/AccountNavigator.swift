import UIKit

protocol AccountNavigatorType {
    func toBackView()
    func toLogin()
    func toEditProfile(user: User)
    func toComment(post: Post)
    func toChat(receiver: User)
    func toPost(postId: String, currentUserId: String)
}

struct AccountNavigator: AccountNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    unowned let window: UIWindow!
    
    func toBackView() {
        navigationController.popViewController(animated: true)
    }
    
    func toLogin() {
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
        window.makeKeyAndVisible()
    }
    
    func toEditProfile(user: User) {
        let viewController = EditProfileViewController.instantiate()
        let navigator = EditProfileNavigator(navigationController: navigationController)
        let useCase = EditProfileUseCase()
        let viewModel = EditProfileViewModel(useCase: useCase, navigator: navigator,
                                             user: user)
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
    
    func toChat(receiver: User) {
        let viewController = ChatViewController.instantiate()
        let useCase = ChatUseCase()
        let navigator = ChatNavigator(navigationController: navigationController,
                                      customTabbar: customTabbar)
        let viewModel = ChatViewModel(useCase: useCase, navigator: navigator, receiver: receiver)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        customTabbar.isHidden = true
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
