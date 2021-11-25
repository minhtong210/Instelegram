import ObjectMapper

struct Post {
    var caption = ""
    var likes = ["": false]
    var geoLocation = ""
    var ownerId = ""
    var postId = ""
    var username = ""
    var profileURL = ""
    var mediaUrl = ""
    var date = 0.0
    var likeCount = 0
}

extension Post: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        caption <- map["caption"]
        likes <- map["likes"]
        geoLocation <- map["geoLocation"]
        ownerId <- map["ownerId"]
        postId <- map["postId"]
        username <- map["username"]
        profileURL <- map["profileURL"]
        mediaUrl <- map["mediaUrl"]
        date <- map["date"]
        likeCount <- map["likeCount"]
    }
}
