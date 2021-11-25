import Foundation
import RxSwift

protocol NotificationRepositoryType {
    func getNotices() -> Observable<[Notification]>
}

struct NotificationRepository: NotificationRepositoryType {
    private let currentUser = FBaseAuth.share.getCurrentUser()
    
    func getNotices() -> Observable<[Notification]> {
        return NotificationFirestore.share.getNotices(of: currentUser.userId)
    }
}
