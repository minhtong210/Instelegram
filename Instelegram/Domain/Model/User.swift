import ObjectMapper

struct User {
    var userId = ""
    var email = ""
    var profileImageUrl = ""
    var username = ""
    var bio = ""
}
extension User: BaseModel {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        email <- map["email"]
        profileImageUrl <- map["profileImageUrl"]
        username <- map["username"]
        bio <- map["bio"]
    }
}
