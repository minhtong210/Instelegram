import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import Then

fileprivate enum Constaints {
    static let tabBarHeight: CGFloat = 110
}

final class MainViewController: UITabBarController, Bindable {
    var customTabBar: CustomTabBar!
    var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input()
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.tabItems
            .drive(tabItemBinder)
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Main")
    }
}
//MARK: - Update UI
extension MainViewController {
    private func configView() {
    }
    
    private func loadTabBar(items: [TabItem]) {
        tabBar.isHidden = true
        setupCustomTabBar(items)
        selectedIndex = 0 // Set default selected index thành item đầu tiên
    }
    
    private func setupCustomTabBar(_ menuItems: [TabItem]) {
        tabBar.frame.size.height = Constaints.tabBarHeight
        
        // Khởi tạo custom tab bar
        customTabBar = CustomTabBar(menuItems: menuItems, frame: tabBar.frame).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.itemTapped = changeTab(tab:)
            view.addSubview($0)
            
            // Auto layout cho custom tab bar
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                $0.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
                $0.heightAnchor.constraint(equalToConstant: tabBar.frame.height),
                $0.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
            ])
        }
        // Thêm lần lượt các view controller
        initHome()
        initPopular()
        initAdd()
        initLike()
        initAccount()
        
        view.layoutIfNeeded()
    }
    
    private func changeTab(tab: Int) {
        selectedIndex = tab
    }
    
    private func initHome() {
        let viewController = HomeViewController.instantiate()
        let navigation = UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.isHidden = true
        }
        let useCase = HomeUseCase()
        let navigator = HomeNavigator(navigationController: navigation,
                                      customTabbar: customTabBar,
                                      window: viewModel.navigator.window)
        let viewModel = HomeViewModel(useCase: useCase, navigator: navigator,
                                      currentUserId: viewModel.userId)
        viewController.bindViewModel(to: viewModel)
        
        viewControllers = [navigation]
    }
    
    private func initPopular() {
        let viewController = PopularViewController.instantiate()
        let navigation = UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.isHidden = true
        }
        let navigator = PopularNavigator(navigationController: navigation,
                                         customTabbar: customTabBar,
                                         window: viewModel.navigator.window)
        let useCase = PopularUseCase()
        let viewModel = PopularViewModel(navigator: navigator, useCase: useCase,
                                         userId: viewModel.userId)
        viewController.bindViewModel(to: viewModel)
        
        viewControllers?.append(navigation)
    }
    
    private func initAdd() {
        let viewController = AddViewController.instantiate()
        let navigation = UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.isHidden = true
        }
        let useCase = AddUseCase()
        let navigator = AddNavigator(navigationController: navigation)
        let viewModel = AddViewModel(useCase: useCase, navigator: navigator)
        viewController.bindViewModel(to: viewModel)
        viewControllers?.append(navigation)
    }
    
    private func initLike() {
        let viewController = LikeViewController.instantiate()
        let navigation = UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.isHidden = true
        }
        let navigator = LikeNavigator(navigationController: navigation,
                                      customTabbar: customTabBar,
                                      window: viewModel.navigator.window)
        let useCase = LikeUseCase()
        let viewModel = LikeViewModel(useCase: useCase, navigator: navigator,
                                      currentUserId: viewModel.userId)
        viewController.bindViewModel(to: viewModel)
        
        viewControllers?.append(navigation)
    }
    
    private func initAccount() {
        let viewController = AccountViewController.instantiate()
        let navigation = UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.isHidden = true
        }
        let navigator = AccountNavigator(navigationController: navigation,
                                         customTabbar: customTabBar,
                                         window: viewModel.navigator.window)
        let useCase = AccountUseCase()
        let viewModel = AccountViewModel(useCase: useCase, navigator: navigator,
                                         userId: viewModel.userId)
        viewController.bindViewModel(to: viewModel)
        
        viewControllers?.append(navigation)
    }
}

//MARK: - Reactive
extension MainViewController {
    private var tabItemBinder: Binder<[TabItem]> {
        return Binder(self) { vc, items in
            vc.loadTabBar(items: items)
        }
    }
}

extension MainViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.main.storyboard
}
