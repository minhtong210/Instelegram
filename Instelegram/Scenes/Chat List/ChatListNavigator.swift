import UIKit

protocol ChatListNavigatorType {
    func toBackView()
    func toChat(receiver: User)
}

struct ChatListNavigator: ChatListNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    
    func toBackView() {
        navigationController.popViewController(animated: true)
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
}
