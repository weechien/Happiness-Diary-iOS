import UIKit

class MainGuidanceCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ImageViewObserveDidSetDelegate {
    
    var guidanceType: GuidanceHelper?
    var guidance: [GuidanceModel]?
    var lastContentOffset: CGFloat = 0
    let cellId = "cellId"
    let menuBarHeight: CGFloat = 50
    let statusBarHeight:CGFloat = 20
    var initialHeight: CGFloat?
    weak var guidanceController: GuidanceDropDownLauncherDelegate? {
        didSet {
            dropDown.delegate = guidanceController
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    lazy var dropDown: GuidanceDropDownLauncher = {
        let launcher = GuidanceDropDownLauncher()
        return launcher
    }()
    
    override func setupViews() {
        super.setupViews()
        
        initialHeight = frame.height
        
        setupCollectionView()
        collectionView.addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)
    }
    
    // Scroll to the current day
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            let date = Date()
            let cal = Calendar.current
            let day = cal.ordinality(of: .day, in: .year, for: date)
            let indexPath = IndexPath(item: day! - 1, section: 0)
            
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(SubGuidanceCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
            flowLayout.scrollDirection = .vertical
        }
        
        collectionView.backgroundColor = UIColor.white
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    func refreshCell() {
        guidance = GuidanceBuilder.sharedInstance.buildGuidance(helper: guidanceType ?? .None)
        collectionView.reloadData()
    }
    
    // Return the total number of items in the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guidance!.count
    }
    
    // Return a collection cell object for the index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SubGuidanceCell
        cell.guidance = guidance![indexPath.item]
        cell.imageView.cell = cell
        cell.imageView.delegate = self
        cell.imageView.index = CGFloat(indexPath.row)
        cell.dropDownView.addTarget(self, action: #selector(onDropDownClick), for: .touchUpInside)
        
        let font = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? "BeyondTheMountains" : "KaiTi"
        cell.dateView.font = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? UIFont(name: font, size: 20) : UIFont(name: font, size: 23)
        cell.contentsView.font = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? UIFont.systemFont(ofSize: 17) : UIFont(name: font, size: 20)
        cell.sourceView.font = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? UIFont.systemFont(ofSize: 15) : UIFont(name: font, size: 18)
        
        // Force the cells to layout its subviews first
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var cellArray = [SubGuidanceCell]()
        cellArray.append(cell)
        adjustParallaxImage(cells: cellArray, index: CGFloat(indexPath.row))
        
        return cell
    }
    
    // Size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
    
    // Spacing between each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var cellHeightWithSpacing: CGFloat
        var pointee: CGPoint
        
        if frame.height > initialHeight! {
            cellHeightWithSpacing = frame.height
            
            pointee = targetContentOffset.pointee
            
            let index = (pointee.y) / cellHeightWithSpacing
            let roundedIndex = round(index)
            
            pointee = CGPoint(x: -scrollView.contentInset.left, y: roundedIndex * cellHeightWithSpacing)
        } else {
            cellHeightWithSpacing = frame.height
            
            pointee = targetContentOffset.pointee
            
            let index = pointee.y / cellHeightWithSpacing
            let roundedIndex = round(index)
            
            pointee = CGPoint(x: -scrollView.contentInset.left, y: roundedIndex * cellHeightWithSpacing)
        }
        
        targetContentOffset.pointee = pointee
        collectionView.setContentOffset(pointee, animated: true)
    }
    
    func updateParallaxPosition(cell: [SubGuidanceCell]?, index: CGFloat?) {
        adjustParallaxImage(cells: cell, index: index)
    }
    
    func adjustParallaxImage(cells: [SubGuidanceCell]?, index: CGFloat?) {
        let mCells = cells == nil ? collectionView.visibleCells as? [SubGuidanceCell] : cells
        for cell in mCells! {
            let mIndex = index == nil ? CGFloat((collectionView.indexPath(for: cell)?.row)!) : index
            let imageViewWrapperRect = collectionView.convert(cell.imageViewWrapper.center, to: self)
            let offsetDistance = (collectionView.frame.height / 2) - (imageViewWrapperRect.y + (mIndex! * cell.frame.height))
            let maxDistance = (collectionView.frame.height / 2) + (cell.imageViewWrapper.frame.height / 2)
            
            cell.updateParallaxOffset(offsetDistance: offsetDistance, maxDistance: maxDistance , scrollDirection: (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustParallaxImage(cells: nil, index: nil)
    }
    
    func didSetImage(cell: [SubGuidanceCell]?, index: CGFloat?) {
        adjustParallaxImage(cells: cell, index: index)
    }
    
    @objc func onDropDownClick() {
        var mController: DropDownCommunicator?
        dropDown.cell = collectionView.visibleCells.first! as? SubGuidanceCell
        dropDown.guidanceType = guidanceType
        
        if let controller = guidanceController as? GuidanceController {
            mController = controller.dropDownCommunicator
        } else if let controller = guidanceController as? BookmarkController {
            mController = controller.dropDownCommunicator
        }

        if guidanceType == .Encouragement || guidanceType == .BookmarkEncouragement {
            dropDown.bookmarkList = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? mController!.bookmarkDEeng! : mController!.bookmarkDEchi!
        } else if guidanceType == .Gosho || guidanceType == .BookmarkGosho {
            dropDown.bookmarkList = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? mController!.bookmarkDGeng! : mController!.bookmarkDGchi!
        }

        dropDown.showItems()
    }
}

