import RxCocoa
import RxSwift

protocol HomeUseCaseType {
    func getUserPosts(userId: String) -> Observable<[Post]>
    func likePost(_ state: Bool, post: Post)
    func getUserFollowings(userId: String) -> Observable<[String]>
    func getFollowingUserPosts(from currentUserId: String,
                               followingUserIds: [String]) -> Observable<[Post]>
}

struct HomeUseCase: HomeUseCaseType {
    private let userRepository = UserRepository()
    private let postRepository = PostRepository()
    
    func getUserPosts(userId: String) -> Observable<[Post]> {
        return postRepository.getUserPosts(userId: userId)
    }
    
    func likePost(_ state: Bool, post: Post) {
        return postRepository.likePost(state, post: post)
    }
    
    func getUserFollowings(userId: String) -> Observable<[String]> {
        return userRepository.getUserFollowings(userId: userId)
    }
    
    func getFollowingUserPosts(from currentUserId: String,
                               followingUserIds: [String]) -> Observable<[Post]> {
        return postRepository.getFollowingUserPosts(from: currentUserId,
                                                    followingUserIds: followingUserIds)
    }
}
