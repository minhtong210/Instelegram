import RxCocoa
import RxSwift

protocol SignUpUseCaseType {
    func createUser(username: String, email: String,
                    password: String, imageData: Data) -> Observable<(Bool, String)>
}

struct SignUpUseCase: SignUpUseCaseType {
    private let repository = UserRepository()
    
    func createUser(username: String, email: String,
                    password: String, imageData: Data) -> Observable<(Bool, String)> {
        return repository.createUser(username: username, email: email,
                                     password: password, imageData: imageData)
    }
}
