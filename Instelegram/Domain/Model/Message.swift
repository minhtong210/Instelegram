import ObjectMapper

struct Message {
    var messageId = ""
    var textMessage = ""
    var photoUrl = ""
    var profileUrl = ""
    var senderId = ""
    var username = ""
    var timestamp = 0.0
    var isPhoto = false
}

extension Message: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        messageId <- map["messageId"]
        textMessage <- map["textMessage"]
        photoUrl <- map["photoUrl"]
        profileUrl <- map["profileUrl"]
        senderId <- map["senderId"]
        username <- map["username"]
        timestamp <- map["timestamp"]
        isPhoto <- map["isPhoto"]
    }
}
