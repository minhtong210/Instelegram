import Foundation
import RxSwift
import Firebase

fileprivate enum Constraints {
    static let noticesFieldUserId = "userId"
    static let noticesFieldpostId = "postId"
    static let noticesFieldisLike = "isLike"
    static let noticesFieldisFollow = "isFollow"
    
}

struct NotificationFirestore {
    static let share = NotificationFirestore()
    
    private let usersDoc = Firestore.firestore().collection("users")
    
    private func getUserNotices(of userId: String) -> CollectionReference {
        return usersDoc.document(userId).collection("notifications")
    }
    
    func getNotices(of currentUserId: String) -> Observable<[Notification]> {
        return Observable.create { obs in
            getUserNotices(of: currentUserId)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        obs.onError(error)
                        fatalError(error.localizedDescription)
                    }
                    var notices = [Notification]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let result = Notification(JSON: doc.data()) ?? Notification()
                        notices.append(result)
                    }
                    obs.onNext(notices)
                }
            
            return Disposables.create()
        }
    }
    
    func followNotice(_ state: Bool, currentUserId: String, username: String,
                      userProfileUrl: String, to userId: String) {
        if state {
            let newNoticeId = getUserNotices(of: userId).document().documentID
            let newLikeNotice = Notification(noticeId: newNoticeId,
                                             profileUrl: userProfileUrl,
                                             userId: currentUserId,
                                             username: username,
                                             timestamp: Date().timeIntervalSince1970,
                                             isFollow: true)
                .toJSON()
            getUserNotices(of: userId).document(newNoticeId)
                .setData(newLikeNotice)
        } else {
            getUserNotices(of: userId)
                .whereField(Constraints.noticesFieldisFollow, isEqualTo: true)
                .whereField(Constraints.noticesFieldUserId, isEqualTo: currentUserId)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        doc.reference.delete()
                    }
                }
        }
    
    }
    
    func likeNotice(_ state: Bool, currentUserId: String, username: String,
                    userProfileUrl: String, post: Post) {
        if state, currentUserId != post.ownerId {
            let newNoticeId = getUserNotices(of: post.ownerId).document().documentID
            let newLikeNotice = Notification(noticeId: newNoticeId,
                                             profileUrl: userProfileUrl,
                                             userId: currentUserId,
                                             username: username,
                                             postId: post.postId,
                                             timestamp: Date().timeIntervalSince1970,
                                             isLike: true)
                .toJSON()
            
            getUserNotices(of: post.ownerId).document(newNoticeId)
                .setData(newLikeNotice)
            
        } else {
            getUserNotices(of: post.ownerId)
                .whereField(Constraints.noticesFieldisLike, isEqualTo: true)
                .whereField(Constraints.noticesFieldUserId, isEqualTo: currentUserId)
                .whereField(Constraints.noticesFieldpostId, isEqualTo: post.postId)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        doc.reference.delete()
                    }
                }
        }
    }
    
    func commentNotice(content: String, currentUserId: String, username: String,
                       userProfileUrl: String, post: Post) {
        if currentUserId != post.ownerId {
            let newNoticeId = getUserNotices(of: post.ownerId).document().documentID
            let newLikeNotice = Notification(noticeId: newNoticeId,
                                             profileUrl: userProfileUrl,
                                             userId: currentUserId,
                                             username: username,
                                             postId: post.postId,
                                             timestamp: Date().timeIntervalSince1970,
                                             isComment: true,
                                             commentContent: content)
                .toJSON()
            
            getUserNotices(of: post.ownerId).document(newNoticeId)
                .setData(newLikeNotice)
        }
    }
}
