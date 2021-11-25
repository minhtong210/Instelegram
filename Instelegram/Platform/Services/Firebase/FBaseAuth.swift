import Foundation
import RxSwift
import Firebase

fileprivate enum AuthMessage {
    static let registerSuccess = "Register Successfully"
    static let loginSuccess = "Login Succeeded"
    static let logoutSuccess = "Logout Succeeded"
}

struct FBaseAuth {
    static let share = FBaseAuth()
    private let auth = Firebase.Auth.auth()
    
    func getCurrentUser() -> User {
        let currentUser = auth.currentUser
        return User(userId: currentUser?.uid ?? "",
                    profileImageUrl: currentUser?.photoURL?.absoluteString ?? "",
                    username: currentUser?.displayName ?? "")
    }
    
    //MARK: - User
    func createUser(username: String, email: String,
                    password: String, imageData: Data) -> Observable<(Bool,String)> {
        return Observable.create { obs in
            auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    obs.onNext((false, error.localizedDescription))
                    obs.onError(error)
                }
                guard let userId = result?.user.uid else { return }
                
                //Save user profile image to STORAGE and Save user profile to FIRESTORE
                UserFirestore.share.saveProfile(userId: userId, email: email,
                                                 imageData: imageData, username: username,
                                                 bio: "") { error in
                    obs.onNext((false, error.localizedDescription))
                    obs.onError(error)
                }
                
                obs.onNext((true, AuthMessage.registerSuccess))
            }
            return Disposables.create()
        }
    }
    
    func login(email: String, password: String) -> Observable<(Bool,String)> {
        return Observable.create { obs in
            auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    obs.onNext((false, error.localizedDescription))
                    obs.onError(error)
                }
                obs.onNext((true, AuthMessage.loginSuccess))
                obs.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func logout() -> Completable {
        return Completable.create { complete in
            do {
                try auth.signOut()
                print(AuthMessage.logoutSuccess)
                complete(.completed)
            } catch {
                print(error.localizedDescription)
                complete(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func updateUsernameAndImage(username: String, imageUrl: URL?,
                                onError: @escaping (_ error: Error) -> Void) {
        if let changeRequest = auth.currentUser?.createProfileChangeRequest() {
            changeRequest.photoURL = imageUrl
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    onError(error)
                }
            }
        }
    }
}
