import RxCocoa
import RxSwift

protocol SearchUseCaseType {
    func getAllUsers(except currentUserId: String) -> Observable<[User]>
}

struct SearchUseCase: SearchUseCaseType {
    private let repository = SearchRepository()
    
    func getAllUsers(except currentUserId: String) -> Observable<[User]> {
        return repository.getAllUsers(except: currentUserId)
    }
}
