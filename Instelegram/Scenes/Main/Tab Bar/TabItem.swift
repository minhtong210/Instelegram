import UIKit

enum TabItem {
    case home
    case search
    case add
    case notification
    case account
    
    var image: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house")
        case .search:
            return UIImage(systemName: "magnifyingglass")
        case .add:
            return UIImage(systemName: "plus")
        case .notification:
            return UIImage(systemName: "suit.heart")
        case .account:
            return UIImage(systemName: "person")
        }
    }
}
