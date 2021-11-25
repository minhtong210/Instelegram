import RxSwift
import RxCocoa
import UIKit

open class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy,
                                       UIImagePickerControllerDelegate {
    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }
}
