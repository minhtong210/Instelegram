import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct LoginViewModel {
    let useCase: LoginUseCaseType
    let navigator: LoginNavigatorType
}

extension LoginViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let loginTrigger: Driver<Void>
        let signUpTrigger: Driver<Void>
        let emailText: Driver<String>
        let passwordText: Driver<String>
    }
    
    struct Output {
        let navigation: Driver<Void>
        let loginMessage: Driver<String>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let loginMessage = input.loginTrigger
            .withLatestFrom(Driver.combineLatest(input.emailText, input.passwordText))
            .flatMapLatest {
                useCase.login(email: $0.0, password: $0.1)
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
        
        let toSignUp = input.signUpTrigger
            .do(onNext: {
                navigator.toSignUp()
            })
        
        let navigation = Driver.merge(toSignUp)
        
        return Output(navigation: navigation,
                      loginMessage: loginMessage)
    }
}
