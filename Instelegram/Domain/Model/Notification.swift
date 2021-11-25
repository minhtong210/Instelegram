import ObjectMapper

struct Notification {
    var noticeId = ""
    var profileUrl = ""
    var userId = ""
    var username = ""
    var postId = ""
    var timestamp = 0.0
    var isFollow = false
    var isLike = false
    var isComment = false
    var commentContent = ""
    var content: String {
        if isLike {
            return "\(username) liked your post"
        } else if isFollow {
            return "\(username) followed you"
        } else {
            return "\(username) commented on your post"
        }
    }
}

extension Notification: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        noticeId <- map["noticeId"]
        profileUrl <- map["profileUrl"]
        userId <- map["userId"]
        username <- map["username"]
        postId <- map["postId"]
        timestamp <- map["timestamp"]
        isFollow <- map["isFollow"]
        isLike <- map["isLike"]
        isComment <- map["isComment"]
        commentContent <- map["commentContent"]
    }
}
