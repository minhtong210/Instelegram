import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct HomeViewModel {
    let useCase: HomeUseCaseType
    let navigator: HomeNavigatorType
    let currentUserId: String
}

extension HomeViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let sendTrigger: Driver<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let posts = input.loadTrigger
            .flatMapLatest {
                useCase.getUserFollowings(userId: currentUserId)
                    .asDriverOnErrorJustComplete()
            }
            .flatMapLatest {
                useCase.getFollowingUserPosts(from: currentUserId, followingUserIds: $0)
                    .asDriverOnErrorJustComplete()
            }
            .map { posts in
                posts.sorted { $0.date > $1.date }
            }
        
        let toChat = input.sendTrigger
            .do(onNext: {
                navigator.toChatList()
            })
        
        let navigation = Driver.merge(toChat)
        
        return Output(posts: posts,
                      navigation: navigation)
    }
}
