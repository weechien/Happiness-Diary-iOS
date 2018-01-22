import UIKit

protocol BookmarkCellDelegate: class {
    func getGuidanceModel(guidanceType: GuidanceHelper) -> [GuidanceModel]
}

class BookmarkBaseCell: MainGuidanceCell {
    weak var delegate: BookmarkCellDelegate?
    
    lazy var emptyViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emptyImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_smiley")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emptyTextView: UITextView = {
        let view = UITextView()
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = UIColor.rgb(red: 153, green: 153, blue: 153)
        view.text = self.guidanceType == .BookmarkEncouragement ? "favorite_encouragement".localOther : "favorite_gosho".localOther
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        setupEmptyView()
        setupEmptySubviews()
        collectionView.backgroundView = emptyViewContainer
        emptyViewContainer.isHidden = true
    }
    
    private func setupEmptyView() {
        addSubview(emptyViewContainer)
        
        emptyViewContainer.frame = frame
        addConstraintsWithFormat(format: "H:|[v0]|", views: emptyViewContainer)
        addConstraintsWithFormat(format: "V:|[v0]|", views: emptyViewContainer)
    }
    
    private func setupEmptySubviews() {
        emptyViewContainer.addSubview(emptyImageView)
        emptyViewContainer.addSubview(emptyTextView)
        
        emptyImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        emptyImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        emptyImageView.topAnchor.constraint(equalTo: emptyViewContainer.topAnchor, constant: 16).isActive = true
        emptyImageView.centerXAnchor.constraint(equalTo: emptyViewContainer.centerXAnchor).isActive = true
        
        emptyTextView.widthAnchor.constraint(equalTo: emptyViewContainer.widthAnchor).isActive = true
        emptyTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emptyTextView.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16).isActive = true
        emptyTextView.centerXAnchor.constraint(equalTo: emptyViewContainer.centerXAnchor).isActive = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            if collectionView.numberOfItems(inSection: 0) == 0 {
                emptyViewContainer.isHidden = false
            }
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
}
