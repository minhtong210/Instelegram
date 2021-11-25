import UIKit
import RxSwift
import RxCocoa

protocol CommentNavigatorType {
    func toBackView()
}

struct CommentNavigator: CommentNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    
    func toBackView() {
        customTabbar.isHidden = false
        navigationController.popViewController(animated: true)
    }
}
