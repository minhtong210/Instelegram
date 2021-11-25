import Foundation
import RxSwift

protocol FollowRepositoryType {
    func followCheck(to userId: String) -> Observable<Bool>
    func follow(_ state: Bool, to userId: String) -> Completable
}

struct FollowRepository: FollowRepositoryType {
    private let currentUser = FBaseAuth.share.getCurrentUser()
    
    func followCheck(to userId: String) -> Observable<Bool> {
        return FollowFirestore.share.followCheck(from: currentUser.userId, to: userId)
    }
    
    func follow(_ state: Bool, to userId: String) -> Completable {
        NotificationFirestore.share.followNotice(state, currentUserId: currentUser.userId,
                                                 username: currentUser.username,
                                                 userProfileUrl: currentUser.profileImageUrl,
                                                 to: userId)
        return FollowFirestore.share.follow(state, from: currentUser.userId, to: userId)
    }
}
