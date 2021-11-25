import Foundation
import RxSwift
import Firebase

struct FollowFirestore {
    static let share = FollowFirestore()
    
    private let followersDoc = Firestore.firestore().collection("follower")
    private let followingsDoc = Firestore.firestore().collection("following")
    
    private func getFollowingCollection(of userId: String) -> CollectionReference {
        return followingsDoc.document(userId).collection("following")
    }
    
    private func getFollowerCollection(of userId: String) -> CollectionReference {
        return followersDoc.document(userId).collection("follower")
    }
    
    private func getUserFollows(ref: CollectionReference) -> Observable<[String]> {
        return Observable.create { obs in
            ref.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        obs.onError(error)
                        fatalError(error.localizedDescription)
                    } else {
                        var followingIds = [String]()
                        guard let documents = querySnapshot?.documents else { return }
                        for doc in documents {
                            let userId = doc.documentID
                            followingIds.append(userId)
                        }
                        obs.onNext(followingIds)
                    }
                }
            return Disposables.create()
        }
    }
    
    func getUserFollowers(userId: String) -> Observable<[String]> {
        return getUserFollows(ref: getFollowerCollection(of: userId))
    }
    
    func getUserFollowings(userId: String) -> Observable<[String]> {
        return getUserFollows(ref: getFollowingCollection(of: userId))
    }
    
    func followCheck(from currentUserId: String, to userId: String) -> Observable<Bool> {
        return Observable.create { obs in
            getFollowingCollection(of: currentUserId).document(userId)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    if let doc = querySnapshot, doc.exists {
                        obs.onNext(true)
                    } else {
                        obs.onNext(false)
                    }
                }
            return Disposables.create()
        }
        
    }
    
    func follow(_ state: Bool, from currentUserId: String, to userId: String) -> Completable {
        return Completable.create { complete in
            let docRefs = [getFollowingCollection(of: currentUserId).document(userId),
                           getFollowerCollection(of: userId).document(currentUserId)]
            if state {
                docRefs.forEach {
                    $0.setData([:])
                }
            } else {
                docRefs.forEach {
                    $0.getDocument { document, error in
                        if let error = error {
                            complete(.error(error))
                            fatalError(error.localizedDescription)
                        }
                        if let doc = document, doc.exists {
                            doc.reference.delete()
                        }
                    }
                }
            }
            complete(.completed)
            return Disposables.create()
        }
    }
}
