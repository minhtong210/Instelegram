import UIKit
import RxCocoa
import RxSwift
import MGArchitecture
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        bindViewModel()
    }

    private func bindViewModel() {
        guard let window = window else { return }
        let navigator = AppNavigator(window: window)
        let viewModel = AppViewModel(navigator: navigator)
        let input = AppViewModel.Input(loadTrigger: Driver.just(()))
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        output.toMain
            .drive()
            .disposed(by: rx.disposeBag)
    }
}
