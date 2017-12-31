import UIKit

protocol ImageViewObserveDidSetDelegate: class {
    func updateParallaxPosition(cell: [SubGuidanceCell]?, index: CGFloat?)
}

class ImageViewObserveDidSet: UIImageView {
    
    var index: CGFloat?
    var delegate: ImageViewObserveDidSetDelegate?
    weak var cell: SubGuidanceCell?
    
    override var image: UIImage?{
        didSet {
            if image != nil{
                if let mCell = cell {
                    mCell.activityIndicatorView.stopAnimating()
                    
                    if mCell.imageAspectRatio.isNaN {
                        mCell.updateImageViewConstraints()
                        let array: [SubGuidanceCell]? = [mCell]
                        delegate?.updateParallaxPosition(cell: array, index: index)
                    }
                }
            }
        }
    }
}
