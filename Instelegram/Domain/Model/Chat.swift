import ObjectMapper

struct Chat {
    var lastTextMessage = ""
    var profileUrl = ""
    var receiverId = ""
    var username = ""
    var timestamp = 0.0
    var isPhoto = false
}

extension Chat: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        lastTextMessage <- map["lastTextMessage"]
        profileUrl <- map["profileUrl"]
        receiverId <- map["receiverId"]
        username <- map["username"]
        timestamp <- map["timestamp"]
        isPhoto <- map["isPhoto"]
    }
}
