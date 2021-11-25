import RxCocoa
import RxSwift

protocol AccountUseCaseType {
    func logout() -> Observable<Void>
    func currentUserCheck(userId: String) -> Observable<Bool>
    
    func getUserProfile(userId: String) -> Observable<User>
    func getUserPosts(userId: String) -> Observable<[Post]>
    func getUserFollowers(userId: String) -> Observable<Int>
    func getUserFollowings(userId: String) -> Observable<Int>
    
    func likePost(_ state: Bool, post: Post)
    
    func followCheck(to userId: String) -> Observable<Bool>
    func follow(to userId: String) -> Observable<Void>
    func unfollow(to userId: String) -> Observable<Void>
}

struct AccountUseCase: AccountUseCaseType {
    private let userRepository = UserRepository()
    private let postRepository = PostRepository()
    private let followRepository = FollowRepository()
    
    //MARK: - Account
    func currentUserCheck(userId: String) -> Observable<Bool> {
        return userRepository.currentUserCheck(with: userId)
    }
    
    func logout() -> Observable<Void> {
        return userRepository.logout().andThen(.just(()))
    }
    
    //MARK: - Information
    func getUserProfile(userId: String) -> Observable<User> {
        return userRepository.getUserProfile(userId: userId)
    }
    
    func getUserPosts(userId: String) -> Observable<[Post]> {
        return postRepository.getUserPosts(userId: userId)
    }
    
    func getUserFollowers(userId: String) -> Observable<Int> {
        return userRepository.getUserFollowers(userId: userId)
            .map { $0.count }
    }
    
    func getUserFollowings(userId: String) -> Observable<Int> {
        return userRepository.getUserFollowings(userId: userId)
            .map { $0.count }
    }
    
    //MARK: - User Action
    func likePost(_ state: Bool, post: Post) {
        return postRepository.likePost(state, post: post)
    }
    
    //MARK: - Follow
    
    func followCheck(to userId: String) -> Observable<Bool> {
        return followRepository.followCheck(to: userId)
    }
    
    func follow(to userId: String) -> Observable<Void> {
        return followRepository.follow(true, to: userId)
            .andThen(.just(()))
    }
    
    func unfollow(to userId: String) -> Observable<Void> {
        return followRepository.follow(false, to: userId)
            .andThen(.just(()))
    }
}
