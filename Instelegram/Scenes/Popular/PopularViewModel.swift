import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct PopularViewModel {
    let navigator: PopularNavigatorType
    let useCase: PopularUseCaseType
    let userId: String
}

extension PopularViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let postTrigger: Driver<IndexPath>
        let searchDidTouch: Driver<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let posts = input.loadTrigger
            .flatMapLatest {
                useCase.getMostLikesPosts()
                    .asDriverOnErrorJustComplete()
            }
        
        let toPost = input.postTrigger
            .withLatestFrom(posts) {
                navigator.toPost(postId: $1[$0.row].postId, currentUserId: userId)
            }
        
        let toSearch = input.searchDidTouch
            .do(onNext: {
                navigator.toSearch(userId: userId)
            })
        
        let navigation = Driver.merge(toSearch, toPost)
        
        return Output(posts: posts,
                      navigation: navigation)
    }
}
