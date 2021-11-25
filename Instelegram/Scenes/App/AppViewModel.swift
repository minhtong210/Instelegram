import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct AppViewModel {
    let navigator: AppNavigatorType
}

extension AppViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let toMain: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let toMain = input.loadTrigger
            .do(onNext: {
                navigator.toMain()
            })
        
        return Output(toMain: toMain)
    }
}
