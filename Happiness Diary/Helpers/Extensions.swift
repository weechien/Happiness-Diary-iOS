import UIKit

extension UIView {
    // Adding a constraint formatting function to minimize boilerplate codes
    func addConstraintsWithFormat(format: String, views: UIView..., metric: [String: CGFloat]? = nil) {
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: metric, views: viewsDictionary))
    }
    
    // Add the metrics to the constraints
    func addMetricDictionary(_ metric: CGFloat...) -> [String: CGFloat] {
        var metricDictionary = [String: CGFloat]()
        
        for (index, float) in metric.enumerated() {
            let key = "m\(index)"
            metricDictionary[key] = float
        }
        
        return metricDictionary
    }
}

extension UIColor {
    // Shortcut method to list the RGB values
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension String {
    
    var localDate: String {
        return Localizator.sharedInstance.localize(key: "Date", string: self)
    }
    
    var localDE: String {
        return Localizator.sharedInstance.localize(key: "Content_DE", string: self)
    }
    
    var localDG: String {
        return Localizator.sharedInstance.localize(key: "Content_DG", string: self)
    }
    
    var localSource: String {
        return Localizator.sharedInstance.localize(key: "Source", string: self)
    }
    
    var localOther: String {
        return Localizator.sharedInstance.localize(key: "Other", string: self)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func getSubString(start: Int, end: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: start)
        let end = self.index(self.startIndex, offsetBy: end)
        
        return String(self[Range(start..<end)])
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> ()) {
        pushViewController(viewController, animated: animated)
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> ()) {
        popViewController(animated: animated)
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func showToast(message : String) {
        let toastView = UITextView()
        toastView.textContainer.lineFragmentPadding = 10
        toastView.isUserInteractionEnabled = false
        toastView.font = UIFont.systemFont(ofSize: 14)
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toastView.textColor = UIColor.white
        toastView.text = message
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 10;
        toastView.clipsToBounds = true
        
        let width = self.view.frame.size.width - 50
        let extraWidthToRemove = toastView.textContainer.lineFragmentPadding * 2
        let extraHeightToAdd = toastView.textContainerInset.top + toastView.textContainerInset.bottom
        let height = message.height(withConstrainedWidth: width - extraWidthToRemove, font: toastView.font!) + extraHeightToAdd
        toastView.frame = CGRect(x: self.view.frame.size.width / 2 - width / 2, y: self.view.frame.size.height - 100, width: width, height: height)

        self.view.addSubview(toastView)
        UIView.animate(withDuration: 2.0, delay: 3.5, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }
}

extension UITextView {
    func addLineSpacing() {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

