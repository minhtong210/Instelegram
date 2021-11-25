import RxCocoa
import RxSwift

protocol EditProfileUseCaseType  {
    func editProfile(userId: String, imageData: Data,
                     username: String, bio: String) -> Observable<Void>
}

struct EditProfileUseCase: EditProfileUseCaseType {
    private let userRepository = UserRepository()
    
    func editProfile(userId: String, imageData: Data,
                     username: String, bio: String) -> Observable<Void> {
        return userRepository.editProfile(userId: userId, imageData: imageData,
                                          username: username, bio: bio)
            .andThen(.just(()))
    }
    
}
