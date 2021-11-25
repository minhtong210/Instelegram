import RxCocoa
import RxSwift

protocol AddUseCaseType {
    func createPost(caption: String, imageData: Data) -> Observable<Void>
}

struct AddUseCase: AddUseCaseType {
    private let repository = PostRepository()
    
    func createPost(caption: String, imageData: Data) -> Observable<Void> {
        return repository.createPost(caption: caption, imageData: imageData)
            .andThen(.just(()))
    }
}
