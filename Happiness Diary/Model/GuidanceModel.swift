import UIKit

class GuidanceModel: NSObject {
    var backgroundColor: UIColor?
    var image: String?
    var date: String?
    var content: String?
    var source: String?
    var combinedString: NSMutableAttributedString?
    
    func getDate() -> NSMutableAttributedString {
        let dateCount = date!.count
        
        return combinedString?.attributedSubstring(from: NSRange(location: 0, length: dateCount)) as! NSMutableAttributedString
    }
    
    func getContent() -> NSMutableAttributedString {
        let dateCount = date!.count
        let contentCount = content!.count
        
        return combinedString?.attributedSubstring(from: NSRange(location: dateCount + 1, length: contentCount)) as! NSMutableAttributedString
    }
    
    func getSource() -> NSMutableAttributedString {
        let combinedCount = combinedString!.string.count
        let sourceCount = source!.count
        
        let mString = combinedString?.attributedSubstring(from: NSRange(location: combinedCount - sourceCount, length: sourceCount)) as! NSMutableAttributedString
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle: paragraph]
        mString.addAttributes(attributes, range: NSRange(location: 0, length: mString.string.count))
        
        return mString
    }
}
