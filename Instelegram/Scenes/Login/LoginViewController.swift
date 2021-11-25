import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

final class LoginViewController: UIViewController, Bindable {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = LoginViewModel.Input(loadTrigger: Driver.just(()),
                                         loginTrigger: logInButton.rx.tap.asDriver(),
                                         signUpTrigger: signUpButton.rx.tap.asDriver(),
                                         emailText: emailTextField.rx.text.orEmpty.asDriver(),
                                         passwordText: passwordTextField.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.loginMessage
            .drive(messageBinder)
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Login")
    }
    
}
//MARK: - Update UI
extension LoginViewController {
    private func configView() {
        configTextField()
    }
    
    private func configTextField() {
        [emailTextField, passwordTextField].forEach {
            $0?.yellowBorder(width: 1)
            $0?.autocorrectionType = .no
        }
    }
}

//MARK: - Reactive
extension LoginViewController {
    private var messageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.messageLabel.do {
                $0.text = message
                $0.isHidden = false
            }
        }
    }
}

extension LoginViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.login.storyboard
}
