import UIKit

class BookmarkGoshoCell: MainGuidanceCell {
    weak var delegate: BookmarkCellDelegate?
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
}

