import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func yellowBorder(width: CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = AppConstraints.Color.yellow?.cgColor
    }
}
