import Foundation
import UIKit

extension String {
    
    func splitString() -> [String] {
        var stringArr = [String]()
        let trimmed = String(self.filter { !"\n\t\r.".contains($0)})
        
        for (index, _) in trimmed.enumerated() {
            let prefixIndex = index + 1
            let substringPrefix = String(trimmed.prefix(prefixIndex).lowercased())
            stringArr.append(substringPrefix)
        }
        return stringArr
    }
    
    func removeWhiteSpace() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
