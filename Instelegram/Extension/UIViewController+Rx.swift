import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxUIAlert

extension UIViewController {
    func showActionSheet(title: String?,
                         message: String?,
                         actions: [(String, UIAlertAction.Style)]) -> Observable<Int> {
        return Observable.create { [unowned self] obs in
            var actionSheet = [AlertAction]()
            
            actions.enumerated()
                .forEach { (index, action) in
                    actionSheet.append(AlertAction(title: action.0, type: index, style: action.1))
                }
            rx.alert(title: title,
                     message: message,
                     actions: actionSheet,
                     preferredStyle: .actionSheet)
                .subscribe(onNext: { output in
                    obs.onNext(output.index)
                    obs.onCompleted()
                })
                .disposed(by: rx.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func showAlert(title: String?,
                   message: String?) -> Observable<Void> {
        return Observable.create { [unowned self] obs in
            rx.alert(title: title, message: message)
                .subscribe(onNext: { _ in
                    obs.onCompleted()
                })
                .disposed(by: rx.disposeBag)
            
            return Disposables.create()
        }
    }
}
