import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

final class SignUpViewController: UIViewController, Bindable {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var addImageButton: UIButton!
    
    var viewModel: SignUpViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = SignUpViewModel.Input(loadTrigger: Driver.just(()),
                                          loginTrigger: logInButton.rx.tap.asDriver(),
                                          signUpTrigger: signUpButton.rx.tap.asDriver(),
                                          addImageTrigger: addImageButton.rx.tap.asDriver(),
                                          usernameText: userNameTextField.rx.text.orEmpty.asDriver(),
                                          emailText: emailTextField.rx.text.orEmpty.asDriver(),
                                          passwordText: passwordTextField.rx.text.orEmpty.asDriver(),
                                          userImageView: Driver.just(userImageView))
        
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.newUserMessage
            .drive(messageBinder)
            .disposed(by: rx.disposeBag)

        output.userImage
            .drive(userImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        output.isSignUpEnable
            .drive(signUpBinder)
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Sign Up")
    }
    
}

//MARK: - Reactive
extension SignUpViewController {
    private var messageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.messageLabel.do {
                $0.text = message
                $0.isHidden = false
            }
        }
    }
    
    private var signUpBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            vc.signUpButton.do {
                $0.isEnabled = bool
                $0.alpha = bool ? 1 : 0.5
            }
        }
    }
    
}

//MARK: - Update UI
extension SignUpViewController {
    private func configView() {
        configTextField()
        configSignUpButton()
    }
    
    private func configTextField() {
        [emailTextField, passwordTextField, userNameTextField, userImageView].forEach {
            $0?.yellowBorder(width: 1)
        }
    }
    private func configSignUpButton() {
        signUpButton.do {
            $0.isEnabled = false
            $0.alpha = 0.5
        }
    }
}

extension SignUpViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.signUp.storyboard
}
