import RxSwift
import Foundation

protocol PostRepositoryType {
    func createPost(caption: String, imageData: Data) -> Completable
    func likePost(_ state: Bool, post: Post)
    
    func getPost(with postId: String) -> Observable<Post>
    func getUserPosts(userId: String) -> Observable<[Post]>
    func getFollowingUserPosts(from currentUserId: String,
                               followingUserIds: [String]) -> Observable<[Post]>
    
    func getMostLikesPosts() -> Observable<[Post]>
}

struct PostRepository: PostRepositoryType {
    private let currentUser = FBaseAuth.share.getCurrentUser()
    
    func createPost(caption: String, imageData: Data) -> Completable {
        return Completable.create { complete in
            PostFirestore.share.savePost(caption: caption, imageData: imageData) { error in
                complete(.error(error))
                fatalError(error.localizedDescription)
            }
            complete(.completed)
            return Disposables.create()
        }
    }
    
    func likePost(_ state: Bool, post: Post) {
        PostFirestore.share.likePost(state, from: currentUser.userId, post: post)
        NotificationFirestore.share.likeNotice(state, currentUserId: currentUser.userId,
                                               username: currentUser.username,
                                               userProfileUrl: currentUser.profileImageUrl,
                                               post: post)
    }
    
    func getPost(with postId: String) -> Observable<Post> {
        return PostFirestore.share.getPost(with: postId)
    }
    
    func getUserPosts(userId: String) -> Observable<[Post]> {
        return PostFirestore.share.getUserPosts(userId: userId)
    }
    
    func getFollowingUserPosts(from currentUserId: String,
                               followingUserIds: [String]) -> Observable<[Post]> {
        return PostFirestore.share.getFollowingUserPosts(from: currentUserId,
                                                          followingUserIds: followingUserIds)
    }
    
    func getMostLikesPosts() -> Observable<[Post]> {
        return PostFirestore.share.getMostLikesPosts()
    }
}
