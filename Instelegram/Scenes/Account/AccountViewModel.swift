import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct AccountViewModel {
    let useCase: AccountUseCaseType
    let navigator: AccountNavigatorType
    let userId: String
}

extension AccountViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let logoutTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let editTrigger: Driver<Void>
        let followTrigger: Driver<Void>
        let sendTrigger: Driver<Void>
        let postTrigger: Driver<IndexPath>
    }
    
    struct Output {
        let accountInfo: Driver<(User, Int, Int, Int)>
        let isCurrentUser: Driver<Bool>
        let isFollowing: Driver<Bool>
        let posts: Driver<[Post]>
        let followTrigger: Driver<Void>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let isCurrentUser = input.loadTrigger
            .flatMapLatest {
                useCase.currentUserCheck(userId: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let isFollowing = input.loadTrigger
            .flatMapLatest {
                useCase.followCheck(to: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let followTrigger = input.followTrigger
            .withLatestFrom(isFollowing)
            .flatMapLatest { isFollowing in
                isFollowing ?
                    useCase.unfollow(to: userId).asDriverOnErrorJustComplete() :
                    useCase.follow(to: userId).asDriverOnErrorJustComplete()
            }
        
        let profile = input.loadTrigger
            .flatMapLatest {
                useCase.getUserProfile(userId: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let posts = input.loadTrigger
            .flatMapLatest {
                useCase.getUserPosts(userId: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let followers = input.loadTrigger
            .flatMapLatest {
                useCase.getUserFollowers(userId: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let followings = input.loadTrigger
            .flatMapLatest {
                useCase.getUserFollowings(userId: userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let accountInfo = Driver.combineLatest(profile, posts, followers, followings)
            .map { return ($0, $1.count, $2, $3) }
        
        let toEditProfile = input.editTrigger
            .withLatestFrom(profile)
            .do(onNext: {
                navigator.toEditProfile(user: $0)
            })
            .mapToVoid()
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let toChat = input.sendTrigger
            .withLatestFrom(profile)
            .do(onNext: {
                navigator.toChat(receiver: $0)
            })
            .mapToVoid()
        
        let toPost = input.postTrigger
            .withLatestFrom(posts) {
                navigator.toPost(postId: $1[$0.row].postId, currentUserId: userId)
            }
        
        let logout = input.logoutTrigger
            .flatMapLatest {
                useCase.logout()
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: {
                navigator.toLogin()
            })
        
        let navigation = Driver.merge(logout, toBackView, toEditProfile, toChat, toPost)
        
        return Output(accountInfo: accountInfo,
                      isCurrentUser: isCurrentUser,
                      isFollowing: isFollowing,
                      posts: posts, followTrigger: followTrigger,
                      navigation: navigation)
    }
}
