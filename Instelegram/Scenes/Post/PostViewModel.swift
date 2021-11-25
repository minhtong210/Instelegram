import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct PostViewModel {
    let useCase: PostUseCaseType
    let navigator: PostNavigatorType
    let currentUserId: String
    let postId: String
}

extension PostViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let likeTrigger: Driver<Void>
        let commentTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let usernameTrigger: Driver<Void>
    }
    
    struct Output {
        let post: Driver<Post>
        let comments: Driver<[Comment]>
        let likeTrigger: Driver<Void>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let post = input.loadTrigger
            .flatMapLatest {
                useCase.getPost(with: postId)
                    .asDriverOnErrorJustComplete()
            }
        
        let comments = post
            .flatMapLatest {
                useCase.getPostComments(from: $0)
                    .asDriverOnErrorJustComplete()
            }
        
        let likeTrigger = input.likeTrigger
            .withLatestFrom(post)
            .flatMapLatest {
                return useCase.likePost(currentUserId: currentUserId, post: $0)
                    .asDriverOnErrorJustComplete()
            }
        
        let toAccount = input.usernameTrigger
            .withLatestFrom(post) {
                if currentUserId != $1.ownerId {
                    navigator.toAccount(userId: $1.ownerId)
                }
            }
        
        let toComment = input.commentTrigger
            .withLatestFrom(post)
            .do(onNext: {
                navigator.toComment(post: $0)
            })
            .mapToVoid()
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let navigation = Driver.merge(toBackView, toComment, toAccount)
        
        return Output(post: post,
                      comments: comments,
                      likeTrigger: likeTrigger,
                      navigation: navigation)
    }
}
