import RxCocoa
import RxSwift

protocol PopularUseCaseType {
    func getMostLikesPosts() -> Observable<[Post]>
}

struct PopularUseCase: PopularUseCaseType {
    private let repository = PostRepository()
    
    func getMostLikesPosts() -> Observable<[Post]> {
        return repository.getMostLikesPosts()
    }
}
