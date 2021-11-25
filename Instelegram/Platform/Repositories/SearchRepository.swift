import RxSwift
import Foundation

protocol SearchRepositoryType {
    func getAllUsers(except currentUserId: String) -> Observable<[User]>
}

struct SearchRepository: SearchRepositoryType {
    func getAllUsers(except currentUserId: String) -> Observable<[User]> {
        return UserFirestore.share.getAllUsers(except: currentUserId)
    }
}
