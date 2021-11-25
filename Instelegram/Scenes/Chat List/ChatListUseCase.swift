import RxCocoa
import RxSwift

protocol ChatListUseCaseType {
    func getUserChatList() -> Observable<[Chat]>
    func getUserProfile(of userId: String) -> Observable<User>
}

struct ChatListUseCase: ChatListUseCaseType {
    private let messageRepository = MessageRepository()
    private let userRepository = UserRepository()
    
    func getUserChatList() -> Observable<[Chat]> {
        return messageRepository.getUserChatList()
    }
    
    func getUserProfile(of userId: String) -> Observable<User> {
        return userRepository.getUserProfile(userId: userId)
    }
}
