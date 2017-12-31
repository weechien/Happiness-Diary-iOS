import UIKit

protocol BookmarkCellDelegate: class {
    func getGuidanceModel(guidanceType: GuidanceHelper) -> [GuidanceModel]
}

class BookmarkEncouragementCell: MainGuidanceCell {
    weak var delegate: BookmarkCellDelegate?
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
}

