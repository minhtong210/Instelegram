import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct ChatListViewModel {
    let useCase: ChatListUseCaseType
    let navigator: ChatListNavigatorType
}

extension ChatListViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let chatSelected: Driver<IndexPath>
    }
    
    struct Output {
        let chatList: Driver<[Chat]>
        let navigation: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let chatList = input.loadTrigger
            .flatMapLatest {
                useCase.getUserChatList()
                    .asDriverOnErrorJustComplete()
            }
        
        let toChat = input.chatSelected
            .withLatestFrom(chatList) {
                return $1[$0.row].receiverId
            }
            .flatMapLatest {
                useCase.getUserProfile(of: $0)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: {
                navigator.toChat(receiver: $0)
            })
            .mapToVoid()
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        let navigation = Driver.merge(toChat, toBackView)
        
        return Output(chatList: chatList,
                      navigation: navigation)
    }
}
