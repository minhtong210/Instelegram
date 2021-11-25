import Foundation
import RxSwift
import Firebase

fileprivate enum Constraints {
    static let messagesOrderByTime = "timestamp"
}

struct MessageFirestore {
    static let share = MessageFirestore()
    
    private let usersDoc = Firestore.firestore().collection("users")
    
    private func getConversations(from senderId: String, to receiverId: String) -> CollectionReference {
        return usersDoc.document(senderId).collection("chats").document(receiverId).collection("messages")
    }
    
    private func getUserChatList(from senderId: String, to receiverId: String) -> DocumentReference {
        return usersDoc.document(senderId).collection("chats").document(receiverId)
    }
    
    func sendMessage(currentUserId: String, username: String, userProfileUrl: String,
                     textMessage: String, receiver: User) -> Completable {
        return Completable.create { complete in
            let messageId = getConversations(from: currentUserId, to: receiver.userId).document().documentID
            
            let newMessage = Message(messageId: messageId, textMessage: textMessage, photoUrl: "",
                                     profileUrl: userProfileUrl, senderId: currentUserId, username: username,
                                     timestamp: Date().timeIntervalSince1970, isPhoto: false)
            let messageJson = newMessage.toJSON()
            
            [getConversations(from: currentUserId, to: receiver.userId),
             getConversations(from: receiver.userId, to: currentUserId)].forEach {
                $0.document(messageId).setData(messageJson) { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
             }
            
            let newChatforCurrentUser = Chat(lastTextMessage: textMessage, profileUrl: receiver.profileImageUrl,
                                             receiverId: receiver.userId, username: receiver.username,
                                             timestamp: Date().timeIntervalSince1970, isPhoto: false)
                .toJSON()
            
            getUserChatList(from: currentUserId, to: receiver.userId)
                .setData(newChatforCurrentUser)
            
            let newChatForReceiver = Chat(lastTextMessage: textMessage, profileUrl: userProfileUrl,
                                          receiverId: currentUserId, username: username,
                                          timestamp: Date().timeIntervalSince1970, isPhoto: false)
                .toJSON()
            
            getUserChatList(from: receiver.userId, to: currentUserId)
                .setData(newChatForReceiver)
            
            return Disposables.create()
        }
    }
    
    func sendPhotoMessage(currentUserId: String, username: String, userProfileUrl: String,
                          imageData: Data, receiver: User) -> Completable {
        return Completable.create { complete in
            let messageId = getConversations(from: currentUserId, to: receiver.userId).document().documentID
            
            //Save User Profile Image to STORAGE
            FBaseStorage.share.saveMessageImage(messageId: messageId,
                                                imageData: imageData) { error in
                fatalError(error.localizedDescription)
            } passMediaUrl: { mediaUrl in
                let newMessage = Message(messageId: messageId, textMessage: "", photoUrl: mediaUrl,
                                         profileUrl: userProfileUrl, senderId: currentUserId, username: username,
                                         timestamp: Date().timeIntervalSince1970, isPhoto: true)
                let messageJson = newMessage.toJSON()
                
                [getConversations(from: currentUserId, to: receiver.userId),
                 getConversations(from: receiver.userId, to: currentUserId)].forEach {
                    $0.document(messageId).setData(messageJson) { error in
                        if let error = error {
                            fatalError(error.localizedDescription)
                        }
                    }
                 }
                [getUserChatList(from: currentUserId, to: receiver.userId),
                 getUserChatList(from: receiver.userId, to: currentUserId)].forEach {
                    $0.setData(messageJson) { error in
                        if let error = error {
                            fatalError(error.localizedDescription)
                        }
                    }
                 }
            }
            return Disposables.create()
        }
    }
    
    func getMessages(between currentUserId: String, and userId: String) -> Observable<[Message]> {
        return Observable.create { obs in
            getConversations(from: currentUserId, to: userId)
                .order(by: Constraints.messagesOrderByTime, descending: false)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        obs.onError(error)
                        fatalError(error.localizedDescription)
                    }
                    var messages = [Message]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let result = Message(JSON: doc.data()) ?? Message()
                        messages.append(result)
                    }
                    obs.onNext(messages)
                }
            return Disposables.create()
        }
    }
    
    func getUserChatList(of currentUserId: String) -> Observable<[Chat]> {
        return Observable.create { obs in
            usersDoc.document(currentUserId).collection("chats")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        obs.onError(error)
                        fatalError(error.localizedDescription)
                    }
                    var chats = [Chat]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let result = Chat(JSON: doc.data()) ?? Chat()
                        chats.append(result)
                    }
                    obs.onNext(chats)
                }
            return Disposables.create()
        }
    }
}
