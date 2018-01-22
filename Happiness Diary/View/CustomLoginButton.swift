import UIKit

class CustomLoginButton: UIButton {
    var defaultBackgroundColor = UIColor.white
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1
        }
    }
}
