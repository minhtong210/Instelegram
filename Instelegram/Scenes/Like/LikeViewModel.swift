import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct LikeViewModel {
    let useCase: LikeUseCaseType
    let navigator: LikeNavigatorType
    let currentUserId: String
}

extension LikeViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let noticeTrigger: Driver<IndexPath>
    }
    
    struct Output {
        let notices: Driver<[Notification]>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let notices = input.loadTrigger
            .flatMapLatest {
                useCase.getNotices()
                    .asDriverOnErrorJustComplete()
            }
        
        let toPost = input.noticeTrigger
            .withLatestFrom(notices) {
                navigator.toPost(postId: $1[$0.row].postId,
                                 currentUserId: currentUserId)
            }
        
        let navigation = Driver.merge(toPost)
        
        return Output(notices: notices,
                      navigation: navigation)
    }
}
