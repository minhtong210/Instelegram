import RxSwift
import Foundation

protocol UserRepositoryType {
    func login(email: String, password: String) -> Observable<(Bool,String)>
    func createUser(username: String, email: String,
                    password: String, imageData: Data) -> Observable<(Bool, String)>
    func editProfile(userId: String, imageData: Data,
                     username: String, bio: String) -> Completable
    func logout() -> Completable
    
    func currentUserCheck(with userId: String) -> Observable<Bool>
    func getCurrentUser() -> User
    
    func getUserProfile(userId: String) -> Observable<User>

    func getUserFollowers(userId: String) -> Observable<[String]>
    func getUserFollowings(userId: String) -> Observable<[String]>
}

struct UserRepository: UserRepositoryType {
    func login(email: String, password: String) -> Observable<(Bool, String)> {
        return FBaseAuth.share.login(email: email, password: password)
    }
    
    func createUser(username: String, email: String,
                    password: String, imageData: Data) -> Observable<(Bool, String)> {
        return FBaseAuth.share.createUser(username: username, email: email,
                                          password: password, imageData: imageData)
    }
    
    func editProfile(userId: String, imageData: Data,
                     username: String, bio: String) -> Completable {
        
        return UserFirestore.share.editProfile(userId: userId, imageData: imageData,
                                               username: username, bio: bio)
    }
    
    func logout() -> Completable {
        return FBaseAuth.share.logout()
    }
    
    func currentUserCheck(with userId: String) -> Observable<Bool> {
        let currentUserId = getCurrentUser().userId
        return UserFirestore.share.currentUserCheck(currentUserId: currentUserId, userId: userId)
    }
    
    func getCurrentUser() -> User {
        return FBaseAuth.share.getCurrentUser()
    }
    
    func getUserProfile(userId: String) -> Observable<User> {
        return UserFirestore.share.getUserProfile(userId: userId )
    }
    
    func getUserFollowers(userId: String) -> Observable<[String]> {
        return FollowFirestore.share.getUserFollowers(userId: userId)
    }
    
    func getUserFollowings(userId: String) -> Observable<[String]> {
        return FollowFirestore.share.getUserFollowings(userId: userId)
    }
}
