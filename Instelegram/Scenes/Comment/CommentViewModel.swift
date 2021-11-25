import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct CommentViewModel {
    let useCase: CommentUseCaseType
    let navigator: CommentNavigatorType
    let post: Post
}

extension CommentViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let contentText: Driver<String>
        let backTrigger: Driver<Void>
        let sendTrigger: Driver<Void>
    }
    
    struct Output {
        let comments: Driver<[Comment]>
        let isSendEnable: Driver<Bool>
        let sendTrigger: Driver<Void>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let isSendEnable = input.contentText
            .map { !$0.isEmpty }
        
        let comments = input.loadTrigger
            .flatMapLatest {
                useCase.getPostComments(from: post)
                    .asDriverOnErrorJustComplete()
            }
        
        let sendTrigger = input.sendTrigger
            .withLatestFrom(input.contentText)
            .flatMapLatest {
                useCase.comment(of: post, content: $0)
                    .asDriverOnErrorJustComplete()
            }
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let navigation = Driver.merge(toBackView)
        
        return Output(comments: comments,
                      isSendEnable: isSendEnable,
                      sendTrigger: sendTrigger,
                      navigation: navigation)
    }
}
