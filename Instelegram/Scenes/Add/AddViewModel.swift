import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct AddViewModel {
    let useCase: AddUseCaseType
    let navigator: AddNavigatorType
}

extension AddViewModel: ViewModel {
    struct Input {
        let captionText: Driver<String>
        let addImageTrigger: Driver<Void>
        let postTrigger: Driver<Void>
        let userImageView: Driver<UIImageView>
    }
    
    struct Output {
        let postImage: Driver<UIImage?>
        let isPostEnable: Driver<Bool>
        let postTrigger: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let postImage = input.addImageTrigger
            .flatMapLatest {
                navigator.showActionSheet()
                    .asDriverOnErrorJustComplete()
            }
            .map {
                ImagePickerChoice(rawValue: $0) ?? .cancel
            }
            .flatMapLatest {
                navigator.showImagePicker(type: $0)
                    .asDriverOnErrorJustComplete()
            }
            
        let postTrigger = input.postTrigger
            .withLatestFrom(Driver.combineLatest(input.captionText, input.userImageView))
            .flatMapLatest { caption, imageView in
                useCase.createPost(caption: caption,
                                   imageData: imageView.image?.jpegData(compressionQuality: 1) ?? Data())
                    .asDriverOnErrorJustComplete()
            }
        
        let isPostEnable = Driver.combineLatest(input.captionText, input.userImageView)
            .map { !$0.0.isEmpty && ($0.1.image != nil) }
            
        
        return Output(postImage: postImage,
                      isPostEnable: isPostEnable,
                      postTrigger: postTrigger)
    }
}
