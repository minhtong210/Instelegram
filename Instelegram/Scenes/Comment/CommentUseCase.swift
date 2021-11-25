import RxCocoa
import RxSwift

protocol CommentUseCaseType {
    func getPostComments(from post: Post) ->  Observable<[Comment]>
    func comment(of post: Post, content: String) -> Observable<Void>
}

struct CommentUseCase: CommentUseCaseType {
    private let repository = CommentRepository()
    
    func getPostComments(from post: Post) -> Observable<[Comment]> {
        return repository.getPostComments(from: post)
    }
    
    func comment(of post: Post, content: String) -> Observable<Void> {
        return repository.comment(of: post, content: content)
            .andThen(.just(()))
    }
}
