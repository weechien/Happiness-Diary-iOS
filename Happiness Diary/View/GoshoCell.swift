import UIKit

class GoshoCell: MainGuidanceCell {
    
    override var guidanceType: GuidanceHelper? {
        get {
            return .Gosho
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

