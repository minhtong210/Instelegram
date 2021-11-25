import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct SearchViewModel {
    let navigator: SearchNavigatorType
    let useCase: SearchUseCaseType
    let userId: String
}

extension SearchViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let cancelTrigger: Driver<Void>
        let searchText: Driver<String>
        let userSelected: Driver<IndexPath>
    }
    
    struct Output {
        let filterUsers: Driver<[User]>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let allUsers = input.loadTrigger
            .flatMapLatest {
                useCase.getAllUsers(except: userId)
                    .asDriverOnErrorJustComplete()
            }

        let filterUsers = Driver.combineLatest(input.searchText, allUsers)
            .map { text, allUsers in
                allUsers.filter { $0.username.contains(text.lowercased().removeWhiteSpace()) }
            }
        
        let toAccount = input.userSelected
            .withLatestFrom(filterUsers) { a, b in
                navigator.toAccount(userId: b[a.row].userId)
            }
        
        let toBackView = input.cancelTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let navigation = Driver.merge(toBackView, toAccount)
        
        return Output(filterUsers: filterUsers,
                      navigation: navigation)
    }
}
