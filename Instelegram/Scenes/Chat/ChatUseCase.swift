import RxCocoa
import RxSwift

protocol ChatUseCaseType {
    func sendMessage(textMessage: String, receiver: User) -> Observable<Void>
    func sendPhotoMessage(imageData: Data, receiver: User) -> Observable<Void>
    func getMessages(to userId: String) -> Observable<[Message]>
    func getCurrentUser() -> User
}

struct ChatUseCase: ChatUseCaseType {
    private let userRepository = UserRepository()
    private let messageRepository = MessageRepository()
    
    func getCurrentUser() -> User {
        return userRepository.getCurrentUser()
    }
    
    func getMessages(to userId: String) -> Observable<[Message]> {
        return messageRepository.getMessages(to: userId)
    }
    
    func sendPhotoMessage(imageData: Data, receiver: User) -> Observable<Void> {
        return messageRepository.sendPhotoMessage(imageData: imageData, receiver: receiver)
            .andThen(.just(()))
    }
    
    func sendMessage(textMessage: String, receiver: User) -> Observable<Void> {
        return messageRepository.sendMessage(textMessage: textMessage, receiver: receiver)
            .andThen(.just(()))
    }
}
