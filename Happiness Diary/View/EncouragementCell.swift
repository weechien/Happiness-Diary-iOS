import UIKit

class EncouragementCell: MainGuidanceCell {
    
    override var guidanceType: GuidanceHelper? {
        get {
            return .Encouragement
        }
        set {}
    }
    override var guidance: [GuidanceModel]? {
        get {
            return GuidanceBuilder.sharedInstance.buildGuidance(helper: guidanceType ?? .None)
        }
        set {}
    }
}
