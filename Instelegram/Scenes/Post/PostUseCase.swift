import RxCocoa
import RxSwift

protocol PostUseCaseType {
    func getPost(with postId: String) -> Observable<Post>
    func likePost(currentUserId: String, post: Post) -> Observable<Void>
    func getPostComments(from post: Post) -> Observable<[Comment]>
}

struct PostUseCase: PostUseCaseType {
    private let postRepository = PostRepository()
    private let commentRepository = CommentRepository()
    
    func getPostComments(from post: Post) -> Observable<[Comment]> {
        return commentRepository.getPostComments(from: post)
    }
    
    func getPost(with postId: String) -> Observable<Post> {
        return postRepository.getPost(with: postId)
    }
    
    func likePost(currentUserId: String, post: Post) -> Observable<Void> {
        if let isliked = post.likes[currentUserId] {
            return isliked ?
                Observable.just(postRepository.likePost(false, post: post)) :
                Observable.just(postRepository.likePost(true, post: post))
        } else {
            return Observable.just(postRepository.likePost(true, post: post))
        }
        
    }
}
