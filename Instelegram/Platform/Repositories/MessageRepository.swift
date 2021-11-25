import Foundation
import RxSwift

protocol MessageRepositoryType {
    func sendMessage(textMessage: String, receiver: User) -> Completable
    func sendPhotoMessage(imageData: Data, receiver: User) -> Completable
    func getMessages(to userId: String) -> Observable<[Message]>
    func getUserChatList() -> Observable<[Chat]>
}

struct MessageRepository: MessageRepositoryType {
    private let currentUser = FBaseAuth.share.getCurrentUser()
    
    func sendMessage(textMessage: String, receiver: User) -> Completable {
        return MessageFirestore.share.sendMessage(currentUserId: currentUser.userId,
                                                  username: currentUser.username,
                                                  userProfileUrl: currentUser.profileImageUrl,
                                                  textMessage: textMessage, receiver: receiver)
    }
    
    func sendPhotoMessage(imageData: Data, receiver: User) -> Completable {
        return MessageFirestore.share.sendPhotoMessage(currentUserId: currentUser.userId,
                                                  username: currentUser.username,
                                                  userProfileUrl: currentUser.profileImageUrl,
                                                  imageData: imageData, receiver: receiver)
    }
    
    func getMessages(to userId: String) -> Observable<[Message]> {
        return MessageFirestore.share.getMessages(between: currentUser.userId,
                                                  and: userId)
    }
    
    func getUserChatList() -> Observable<[Chat]> {
        return MessageFirestore.share.getUserChatList(of: currentUser.userId)
    }
}
