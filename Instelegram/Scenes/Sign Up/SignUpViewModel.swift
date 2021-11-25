import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct SignUpViewModel {
    let useCase: SignUpUseCaseType
    let navigator: SignUpNavigatorType
}

extension SignUpViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let loginTrigger: Driver<Void>
        let signUpTrigger: Driver<Void>
        let addImageTrigger: Driver<Void>
        let usernameText: Driver<String>
        let emailText: Driver<String>
        let passwordText: Driver<String>
        let userImageView: Driver<UIImageView>
    }
    
    struct Output {
        let navigation: Driver<Void>
        let userImage: Driver<UIImage?>
        let newUserMessage: Driver<String>
        let isSignUpEnable: Driver<Bool>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let userImage = input.addImageTrigger
            .flatMapLatest {
                navigator.showActionSheet()
                    .asDriverOnErrorJustComplete()
            }
            .map {
                ImagePickerChoice(rawValue: $0) ?? .cancel
            }
            .flatMapLatest {
                navigator.showImagePicker(type: $0)
                    .asDriverOnErrorJustComplete()
            }
            
        let isSignUpEnable = Driver.combineLatest(input.usernameText, input.emailText,
                                                  input.passwordText, input.userImageView)
            .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && ($0.3.image != nil) }
        
        let newUserMessage = input.signUpTrigger
            .withLatestFrom(Driver.combineLatest(input.usernameText, input.emailText,
                                                 input.passwordText, input.userImageView))
            .flatMapLatest { username, email, password , imageView in
                useCase.createUser(username: username, email: email,
                                   password: password,
                                   imageData: imageView.image?.jpegData(compressionQuality: 1) ?? Data())
                    .do(onNext: { success, _ in
                        if success {
                            Timer.scheduledTimer(withTimeInterval: 1.5,
                                                 repeats: false) { _ in
                                navigator.toMain()
                            }
                        }
                    })
                    .asDriverOnErrorJustComplete()
            }
            .map { $0.1 }
        
        let toLogin = input.loginTrigger
            .do(onNext: {
                navigator.toLogin()
            })
        
        let navigation = Driver.merge(toLogin)
        
        return Output(navigation: navigation,
                      userImage: userImage,
                      newUserMessage: newUserMessage,
                      isSignUpEnable: isSignUpEnable)
    }
}
