import Foundation
import RxSwift
import Firebase

fileprivate enum Constraints {
    static let postsOrderByTime = "date"
    static let postsById = "ownerId"
    static let postsOrderByLikeCount = "likeCount"
}

struct PostFirestore {
    static let share = PostFirestore()
    
    private let postsDoc = Firestore.firestore().collection("posts")
    private let allPostsDoc = Firestore.firestore().collection("allPosts")
    
    private func getPostCollection(of userId: String) -> CollectionReference {
        return postsDoc.document(userId).collection("posts")
    }
    
    private func getPosts(collectionRef: CollectionReference,
                          order: (name: String, descending: Bool)? = nil,
                          whereField: (name: String, in: [String])? = nil) -> Observable<[Post]> {
        return Observable.create { obs in
            var query: Query {
                if let order = order {
                    return collectionRef
                        .order(by: order.name, descending: order.descending)
                }
                else if let whereField = whereField {
                    return collectionRef
                        .whereField(whereField.name, in: whereField.in)
                }
                else {
                    return collectionRef
                }
            }
            query.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    fatalError(error.localizedDescription)
                } else {
                    var posts = [Post]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let result = Post(JSON: doc.data()) ?? Post()
                        posts.append(result)
                    }
                    obs.onNext(posts)
                }
            }
            return Disposables.create()
        }
    }
    //MARK: - Post
    func savePost(caption: String, imageData: Data,
                  onError: @escaping (_ error: Error) -> Void) {
        
        let currentUser = FBaseAuth.share.getCurrentUser()
        let firestorePostsRef = getPostCollection(of: currentUser.userId).document()
        let postId = firestorePostsRef.documentID
        let firestoreAllPostsRef = allPostsDoc.document(postId)
        
        //Save Post Image to STORAGE and from STORAGE -> get the mediaUrl
        
        FBaseStorage.share.savePostImage(postId: postId, imageData: imageData,
                                         onError: onError) { mediaUrl in
            let newPost = Post(caption: caption, likes: [:],
                               geoLocation: "", ownerId: currentUser.userId,
                               postId: postId,
                               username: currentUser.username,
                               profileURL: currentUser.profileImageUrl,
                               mediaUrl: mediaUrl,
                               date: Date().timeIntervalSince1970, likeCount: 0)
            
            let postJson = newPost.toJSON()
            
            //Save Post to FIREBASE
            [firestorePostsRef, firestoreAllPostsRef].forEach {
                $0.setData(postJson) { error in
                    if let error = error {
                        onError(error)
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    func getPost(with postId: String) -> Observable<Post> {
        return Observable.create { obs in
            allPostsDoc.document(postId).addSnapshotListener { querySnapshot, error in
                if let error = error {
                    obs.onError(error)
                    fatalError(error.localizedDescription)
                } else {
                    guard let data = querySnapshot?.data() else { return }
                    let result = Post(JSON: data) ?? Post()
                    obs.onNext(result)
                }
            }
            return Disposables.create()
        }
    }
    
    func getUserPosts(userId: String) -> Observable<[Post]> {
        return getPosts(collectionRef: getPostCollection(of: userId),
                        order: (name: Constraints.postsOrderByTime, descending: true))
    }
    
    func getFollowingUserPosts(from currentUserId: String,
                               followingUserIds: [String]) -> Observable<[Post]> {
        let allUserIds = [currentUserId] + followingUserIds
        return getPosts(collectionRef: allPostsDoc,
                        whereField: (name: Constraints.postsById, in: allUserIds))
    }
    
    func getMostLikesPosts() -> Observable<[Post]> {
        return getPosts(collectionRef: allPostsDoc,
                        order: (name: Constraints.postsOrderByLikeCount, descending: true))
    }
    //MARK: - Like
    func likePost(_ state: Bool, from userId: String, post: Post) {
        let likeCount = state ? post.likeCount + 1 : post.likeCount - 1
        [getPostCollection(of: post.ownerId).document(post.postId),
         allPostsDoc.document(post.postId)].forEach {
            $0.updateData(["likeCount": likeCount, "likes.\(userId)": state])
         }
    }
}
