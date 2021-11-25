import Foundation
import RxSwift
import Firebase

fileprivate enum Constraints {
    static let commentsOrderByTime = "date"
}

struct CommentFirestore {
    static let share = CommentFirestore()

    private let postsDoc = Firestore.firestore().collection("posts")
    private let allPostsDoc = Firestore.firestore().collection("allPosts")
    
    private func getComments(of post: Post) -> CollectionReference {
        return postsDoc
            .document(post.ownerId).collection("posts")
            .document(post.postId).collection("comments")
    }
    
    private func getCommentsFromAllposts(with postId: String) -> CollectionReference {
        return allPostsDoc
            .document(postId).collection("comments")
    }
    
    func getPostComments(from post: Post) -> Observable<[Comment]> {
        Observable.create { obs in
            getCommentsFromAllposts(with: post.postId)
                .order(by: Constraints.commentsOrderByTime, descending: false)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    var comments = [Comment]()
                    guard let documents = querySnapshot?.documents else { return }
                    for doc in documents {
                        let data = doc.data()
                        let result = Comment(JSON: data) ?? Comment()
                        comments.append(result)
                    }
                    obs.onNext(comments)
                }
            
            return Disposables.create()
        }
        
    }
    
    func comment(of post: Post, content: String, username: String,
                 profileImage: String, currrentUserId: String) -> Completable {
        return Completable.create { complete in
            let newComment = Comment(content: content, username: username,
                                     profileImage: profileImage,
                                     date: Date().timeIntervalSince1970,
                                     ownerId: currrentUserId)
            
            let commentJson = newComment.toJSON()
            
            [getComments(of: post),
             getCommentsFromAllposts(with: post.postId)].forEach {
                $0.addDocument(data: commentJson) { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
            }
                
            return Disposables.create()
        }
    }
}
