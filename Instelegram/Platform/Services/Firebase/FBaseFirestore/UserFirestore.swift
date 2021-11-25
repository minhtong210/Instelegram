import Foundation
import RxSwift
import Firebase

struct UserFirestore {
    static let share = UserFirestore()

    private let usersDoc = Firestore.firestore().collection("users")
    private let postsDoc = Firestore.firestore().collection("posts")
    private let allPostsDoc = Firestore.firestore().collection("allPosts")
    
    private func getPostCollection(of userId: String) -> CollectionReference {
        return postsDoc.document(userId).collection("posts")
    }
    
    func saveProfile(userId: String, email: String, imageData: Data,
                     username: String, bio: String,
                     onError: @escaping (_ error: Error) -> Void) {
        let userDocUsingUserId = usersDoc.document(userId)
        
        //Save User Profile Image to STORAGE
        FBaseStorage.share.saveProfileImage(userId: userId, username: username,
                                            imageData: imageData,
                                            onError: onError) { profileImageUrl in
            
            let newUser = User(userId: userId, email: email,
                               profileImageUrl: profileImageUrl,
                               username: username, bio: bio)
            
            let userJson = newUser.toJSON()
            
            //Save User Profile to FIREBASE
            userDocUsingUserId.setData(userJson) { error in
                if let error = error {
                    onError(error)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func currentUserCheck(currentUserId: String, userId: String) -> Observable<Bool> {
        return Observable.create { obs in
            if currentUserId == userId {
                obs.onNext(true)
            } else {
                obs.onNext(false)
            }
            obs.onCompleted()
            return Disposables.create()
        }
    }
    
    func editProfile(userId: String, imageData: Data,
                     username: String, bio: String) -> Completable {
        return Completable.create { complete in
            let userDocUsingUserId = usersDoc.document(userId)
            
            //Update User Profile Image to STORAGE
            FBaseStorage.share.saveProfileImage(userId: userId, username: username,
                                                imageData: imageData,
                                                onError: { error in
                                                    complete(.error(error))
                                                    fatalError(error.localizedDescription)
                                                }) { profileImageUrl in
                
                let editedData = ["profileImageUrl": profileImageUrl,
                                  "username": username,
                                  "bio": bio]
                
                //Update User Profile to FIREBASE
                userDocUsingUserId.updateData(editedData) { error in
                    if let error = error {
                        complete(.error(error))
                        fatalError(error.localizedDescription)
                    }
                }
                getPostCollection(of: userId)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            complete(.error(error))
                            fatalError(error.localizedDescription)
                        } else {
                            //Get all postId from posts of UserId
                            guard let documents = querySnapshot?.documents else { return }
                            for doc in documents {
                                let result = Post(JSON: doc.data()) ?? Post()
                                
                                //Update username and profileImageUrl for each postId
                                [getPostCollection(of: userId).document(result.postId),
                                 allPostsDoc.document(result.postId)].forEach {
                                    $0.updateData(["username": username, "profileURL": profileImageUrl])
                                 }
                            }
                        }
                    }
                complete(.completed)
            }
            return Disposables.create()
        }
    }
    
    func getUserProfile(userId: String) -> Observable<User> {
        return Observable.create { obs in
            usersDoc.document(userId)
                .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    obs.onError(error)
                    fatalError(error.localizedDescription)
                } else {
                    guard let data = querySnapshot?.data() else { return }
                    let result = User(JSON: data) ?? User()
                    obs.onNext(result)
                }
            }
            return Disposables.create()
        }
    }

    func getAllUsers(except currentUserId: String) -> Observable<[User]> {
        return Observable.create { obs in
            usersDoc.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        obs.onError(error)
                        fatalError(error.localizedDescription)
                    }
                    var users = [User]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let data = doc.data()
                        let result = User(JSON: data) ?? User()
                        if result.userId != currentUserId {
                            users.append(result)
                        }
                    }
                    obs.onNext(users)
                }
            return Disposables.create()
        }
    }
}
