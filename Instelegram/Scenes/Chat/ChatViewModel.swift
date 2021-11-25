import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct ChatViewModel {
    let useCase: ChatUseCaseType
    let navigator: ChatNavigatorType
    let receiver: User
}

extension ChatViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let sendTrigger: Driver<Void>
        let messageText: Driver<String>
    }
    
    struct Output {
        let messages: Driver<[Message]>
        let isSendEnable: Driver<Bool>
        let sendTrigger: Driver<Void>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let isSendEnable = input.messageText
            .map { !$0.isEmpty }
        
        let messages = input.loadTrigger
            .flatMapLatest {
                useCase.getMessages(to: receiver.userId)
                    .asDriverOnErrorJustComplete()
            }
        
        let sendTrigger = input.sendTrigger
            .withLatestFrom(input.messageText)
            .flatMapLatest {
                useCase.sendMessage(textMessage: $0, receiver: receiver)
                    .asDriverOnErrorJustComplete()
            }
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let navigation = Driver.merge(toBackView)
        
        return Output(messages: messages,
                      isSendEnable: isSendEnable,
                      sendTrigger: sendTrigger,
                      navigation: navigation)
    }
}
