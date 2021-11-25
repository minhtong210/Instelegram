import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct MainViewModel {
    let navigator: MainNavigator
    let userId: String
}

extension MainViewModel: ViewModel {
    
    struct Input {
    }
    
    struct Output {
        let tabItems: Driver<[TabItem]>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let tabItems = Driver<[TabItem]>
            .just([.home, .search, .add, .notification, .account])
        
        return Output(tabItems: tabItems)
    }
}
