import UIKit

class DropDownCommunicator: NSObject {
    var bookmarkDEeng: [String]?
    var bookmarkDEchi: [String]?
    var bookmarkDGeng: [String]?
    var bookmarkDGchi: [String]?
    
    func setBookmarkArray(stringArray: [String]?) {
        bookmarkDEeng = stringArray
        bookmarkDEchi = stringArray
        bookmarkDGeng = stringArray
        bookmarkDGchi = stringArray
    }
}
