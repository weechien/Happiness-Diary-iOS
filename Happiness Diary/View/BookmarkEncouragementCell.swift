import UIKit

class BookmarkEncouragementCell: BookmarkBaseCell {

    override var guidanceType: GuidanceHelper? {
        get {
            return .BookmarkEncouragement
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

