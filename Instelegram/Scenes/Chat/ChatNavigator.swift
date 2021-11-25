import UIKit
import RxSwift

protocol ChatNavigatorType {
    func toBackView()
    func showImagePicker() -> Observable<UIImage?>
}

struct ChatNavigator: ChatNavigatorType {
    unowned let navigationController: UINavigationController
    unowned let customTabbar: CustomTabBar
    
    func toBackView() {
        customTabbar.isHidden = false
        navigationController.popViewController(animated: true)
    }
    
    func showImagePicker() -> Observable<UIImage?> {
        return Observable.just(()).flatMapLatest {
            UIImagePickerController.rx.createWithParent(navigationController) { picker in
                picker.sourceType = .photoLibrary
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
}
