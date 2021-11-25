import Foundation
import RxSwift
import Firebase

fileprivate enum Constraints {
    static let imageContentType = "image/jpg"
}

struct FBaseStorage {
    static let share = FBaseStorage()
    
    private let storageProfileImage = Storage.storage().reference().child("profileImage")
    private let storagePosts = Storage.storage().reference().child("posts")
    private let storageMessages = Storage.storage().reference().child("messages")
    
//MARK: - User
    func saveProfileImage(userId: String, username: String,
                          imageData: Data,
                          onError: @escaping (_ error: Error) -> Void,
                          passMediaUrl: @escaping (String) -> Void) {
        let storageUsingUserId = storageProfileImage.child(userId)
        let metaData = StorageMetadata().then {
            $0.contentType = Constraints.imageContentType
        }
        
        //Save profile image to STORAGE
        storageUsingUserId.putData(imageData, metadata: metaData) { storageMetaData, error in
            if let error = error {
                onError(error)
                fatalError(error.localizedDescription)
            }
            
            //Get URL of profile image
            storageUsingUserId.downloadURL { url, error in
                if let error = error {
                    onError(error)
                    fatalError(error.localizedDescription)
                }
                
                if let profileImageUrl = url?.absoluteString {
                    //Pass the mediaUrl to FBaseFirestore
                    passMediaUrl(profileImageUrl)
                    
                    //Update User Name and Image
                    FBaseAuth.share.updateUsernameAndImage(username: username,
                                                           imageUrl: url, onError: onError)
                }
            }
        }
    }
    
//MARK: - Post
    func savePostImage(postId: String, imageData: Data,
                       onError: @escaping (_ error: Error) -> Void,
                       passMediaUrl: @escaping (String) -> Void) {
        let storageUsingPostId = storagePosts.child(postId)
        let metaData = StorageMetadata().then {
            $0.contentType = Constraints.imageContentType
        }
        
        //Save post image to STORAGE
        storageUsingPostId.putData(imageData, metadata: metaData) { storageMetaData, error in
            if let error = error {
                onError(error)
                fatalError(error.localizedDescription)
            }
            
            //Get URL of media file (video / image)
            storageUsingPostId.downloadURL { url, error in
                if let error = error {
                    onError(error)
                    fatalError(error.localizedDescription)
                }
                
                if let mediaUrl = url?.absoluteString {
                    //Pass the mediaUrl to FBaseFirestore
                    passMediaUrl(mediaUrl)
                }
            }
        }
    }
//MARK: - Chat
    func saveMessageImage(messageId: String, imageData: Data,
                          onError: @escaping (_ error: Error) -> Void,
                          passMediaUrl: @escaping (String) -> Void) {
        let storageUsingMessageId = storageProfileImage.child(messageId)
        let metaData = StorageMetadata().then {
            $0.contentType = Constraints.imageContentType
        }
        
        storageUsingMessageId.putData(imageData, metadata: metaData) { storageMetaData, error in
            if let error = error {
                onError(error)
                fatalError(error.localizedDescription)
            }
            
            //Get URL of media file (video / image)
            storageUsingMessageId.downloadURL { url, error in
                if let error = error {
                    onError(error)
                    fatalError(error.localizedDescription)
                }
                
                if let mediaUrl = url?.absoluteString {
                    //Pass the mediaUrl to FBaseFirestore
                    passMediaUrl(mediaUrl)
                }
            }
        }
    }
    
}
