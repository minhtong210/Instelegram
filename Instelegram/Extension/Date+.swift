import Foundation
import UIKit

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter().then {
            $0.unitsStyle = .full
            $0.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
            $0.zeroFormattingBehavior = .dropAll
            $0.maximumUnitCount = 1
        }
        let timeAgoString = String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
        return timeAgoString + " ago"
    }
}
