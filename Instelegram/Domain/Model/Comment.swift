import ObjectMapper

struct Comment {
    var content = ""
    var username = ""
    var profileImage = ""
    var date = 0.0
    var ownerId = ""
}

extension Comment: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        username <- map["username"]
        profileImage <- map["profileImage"]
        date <- map["date"]
        ownerId <- map["ownerId"]
    }
}
