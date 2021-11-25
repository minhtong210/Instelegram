import Foundation
import UIKit

extension NSMutableAttributedString {
    var fontSize: CGFloat { return 16 }
    var boldFont: UIFont {
        return UIFont(name: "Chalkboard SE Bold",
                      size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
    }
    var lightFont: UIFont {
        return UIFont(name: "Chalkboard SE Light",
                      size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func light(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : lightFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
