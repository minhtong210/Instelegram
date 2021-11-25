import RxCocoa
import RxSwift

protocol LikeUseCaseType {
    func getNotices() -> Observable<[Notification]>
}

struct LikeUseCase: LikeUseCaseType {
    private let repository = NotificationRepository()
    
    func getNotices() -> Observable<[Notification]> {
        return repository.getNotices()
    }
}
