import Foundation
import RxSwift

protocol CommentRepositoryType {
    func getPostComments(from post: Post) ->  Observable<[Comment]>
    func comment(of post: Post, content: String) -> Completable
}

struct CommentRepository: CommentRepositoryType {
    private let currentUser = FBaseAuth.share.getCurrentUser()
    
    func getPostComments(from post: Post) -> Observable<[Comment]> {
        return CommentFirestore.share.getPostComments(from: post)
    }
    
    func comment(of post: Post, content: String) -> Completable {
        NotificationFirestore.share.commentNotice(content: content,
                                                  currentUserId: currentUser.userId,
                                                  username: currentUser.username,
                                                  userProfileUrl: currentUser.profileImageUrl,
                                                  post: post)
        return CommentFirestore.share.comment(of: post, content: content,
                                              username: currentUser.username,
                                              profileImage: currentUser.profileImageUrl,
                                              currrentUserId: currentUser.userId)
    }
}
