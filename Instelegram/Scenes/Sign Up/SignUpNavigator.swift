import UIKit
import RxSwift
import RxCocoa

protocol SignUpNavigatorType {
    func toMain()
    func toLogin()
    func showActionSheet() -> Observable<Int>
    func showImagePicker(type: ImagePickerChoice) -> Observable<UIImage?>
}

struct SignUpNavigator: SignUpNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let window: UIWindow
    
    func showActionSheet() -> Observable<Int> {
        return navigationController.showActionSheet(title: nil,
                                                    message: nil,
                                                    actions: [("Take a photo", .default),
                                                              ("Choose Image From Library", .default),
                                                              ("Cancel", .cancel)])
    }
    
    func showImagePicker(type: ImagePickerChoice) -> Observable<UIImage?> {
        if type == .cancel {
            return Observable.just(UIImage(systemName: "person"))
        }
        
        return Observable.just(()).flatMapLatest {
            UIImagePickerController.rx.createWithParent(navigationController) { picker in
                if type == .camera {
                    picker.sourceType = .camera
                    picker.cameraFlashMode = .off
                } else {
                    picker.sourceType = .photoLibrary
                }
                picker.allowsEditing = true
            }
            .flatMap { $0.rx.didFinishPickingMediaWithInfo }
            .take(1)
        }
        .map { info in
            if let image = info[.editedImage] as? UIImage {
                return image
            }
            return info[.originalImage] as? UIImage
        }
    }
    
    func toMain() {
        let userId = FBaseAuth.share.getCurrentUser().userId
        let viewController = MainViewController.instantiate()
        let navigator = MainNavigator(window: window)
        let viewModel = MainViewModel(navigator: navigator, userId: userId)
        viewController.bindViewModel(to: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func toLogin() {
        navigationController.popViewController(animated: true)
    }
}
