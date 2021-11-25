import Foundation
import RxSwift
import RxCocoa
import MGArchitecture

struct EditProfileViewModel {
    let useCase: EditProfileUseCaseType
    let navigator: EditProfileNavigatorType
    let user: User
}

extension EditProfileViewModel: ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let usernameText: Driver<String>
        let bioText: Driver<String>
        let userImageView: Driver<UIImageView>
        let addImageTrigger: Driver<Void>
        let doneTrigger: Driver<Void>
        let backTrigger: Driver<Void>
    }
    
    struct Output {
        let profile: Driver<User>
        let isDoneEnable: Driver<Bool>
        let userImage: Driver<UIImage?>
        let toBackView: Driver<Void>
        let doneTrigger: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        
        let profile = input.loadTrigger
            .map { return user }
        
        let userImage = input.addImageTrigger
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
        
        let doneTrigger = input.doneTrigger
            .withLatestFrom(Driver.combineLatest(input.usernameText, input.userImageView, input.bioText))
            .flatMapLatest { username, userImage, bio in
                useCase.editProfile(userId: user.userId,
                                    imageData: userImage.image?.jpegData(compressionQuality: 1) ?? Data(),
                                    username: username, bio: bio)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: {
                navigator.toBackView()
            })
        
        let isDoneEnable = Driver.combineLatest(input.usernameText, input.userImageView)
            .map { !$0.0.isEmpty && ($0.1.image != nil) }
        
        let toBackView = input.backTrigger
            .do(onNext: {
                navigator.toBackView()
            })
        
        return Output(profile: profile,
                      isDoneEnable: isDoneEnable,
                      userImage: userImage,
                      toBackView: toBackView,
                      doneTrigger: doneTrigger)
    }
}
