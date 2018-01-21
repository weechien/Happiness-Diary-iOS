import UIKit

class BookmarkGoshoCell: BookmarkBaseCell {
    
    override var guidanceType: GuidanceHelper? {
        get {
            return .BookmarkGosho
        }
        set {}
    }
    override var guidance: [GuidanceModel]? {
        get {
            return delegate?.getGuidanceModel(guidanceType: guidanceType ?? .None)
        }
        set {}
    }
}

