import UIKit

enum StoryboardName: String {
    case login = "Login"
    case signUp = "SignUp"
    case main = "Main"
    case home = "Home"
    case popular = "Popular"
    case search = "Search"
    case add = "Add"
    case like = "Like"
    case account = "Account"
    case editProfile = "EditProfile"
    case comment = "Comment"
    case chatList = "ChatList"
    case chat = "Chat"
    case post = "Post"
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
}
