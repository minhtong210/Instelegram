import RxCocoa
import RxSwift

protocol LoginUseCaseType {
    func login(email: String, password: String) -> Observable<(Bool,String)>
}

struct LoginUseCase: LoginUseCaseType {
    private let repository = UserRepository()
    
    func login(email: String, password: String) -> Observable<(Bool, String)> {
        return repository.login(email: email, password: password)
    }
}
