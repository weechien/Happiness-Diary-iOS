import UIKit
import Firebase

class BaseController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MenuBarDelegate, GuidanceDropDownLauncherDelegate {
    var firstCell: UICollectionViewCell.Type
    var secondCell: UICollectionViewCell.Type
    var dropDownCommunicator = DropDownCommunicator()
    var handle: AuthStateDidChangeListenerHandle?
    var statusBar: UIView?
    let menuBarHeight: CGFloat = 50
    let statusBarHeight:CGFloat = 20
    var initialHeight: CGFloat?
    lazy var navTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    
    let encouragementCellId = "encouragementCellId"
    let goshoCellId = "goshoCellId"
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar(selectedColor: UIColor.white, deselectedColor: UIColor.rgb(red: 33, green: 46, blue: 57), horizontalBarColor: UIColor(white: 0.95, alpha: 1))
        mb.delegate = self
        return mb
    }()
    
    init(layout: UICollectionViewLayout, firstCell: UICollectionViewCell.Type = EncouragementCell.self, secondCell: UICollectionViewCell.Type = GoshoCell.self) {
        self.firstCell = firstCell
        self.secondCell = secondCell
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialHeight = view.frame.height
        
        setupCollectionView()
        setupNavigationBar()
        setupMenuBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let loginController = LoginController()
                self.present(loginController, animated: true, completion: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func reloadBookmarkCollectionView(guidanceType: GuidanceHelper) {}
    
    // Setup the collection view
    private func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
            flowLayout.scrollDirection = .horizontal
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        
        // Register the cell object and id to be used
        collectionView?.register(firstCell, forCellWithReuseIdentifier: encouragementCellId)
        collectionView?.register(secondCell, forCellWithReuseIdentifier: goshoCellId)
        
        collectionView?.isPagingEnabled = true
        
        // Set the collection view and scroll indicator's X offset position to be the height of the menu bar
        collectionView?.contentInset = UIEdgeInsets(top: menuBarHeight, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: menuBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    // Setup the menu bar
    private func setupMenuBar() {
        let coverView = UIView()
        coverView.backgroundColor = UIColor.rgb(red: 77, green: 208, blue: 225)
        view.addSubview(coverView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: coverView)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: coverView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat(format: "V:[v0(m0)]", views: menuBar, metric: view.addMetricDictionary(menuBarHeight))
        
        if #available(iOS 11.0, *) {
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    // Setup the navigation bar
    func setupNavigationBar() {
        navTitleLabel.textColor = UIColor.white
        
        navTitleLabel.font = UIFont.systemFont(ofSize: 20)
        navTitleLabel.text = "  " + "guidance".localOther
        navigationItem.titleView = navTitleLabel
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if view.frame.height > initialHeight! - menuBarHeight {
            return CGSize(width: view.frame.width, height: view.frame.height - menuBarHeight - statusBarHeight)
        }
        
        return CGSize(width: view.frame.width, height: view.frame.height - menuBarHeight)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Move the horizontal bar in the menu bar
        menuBar.horizontalBarLeftConstraint?.constant = scrollView.contentOffset.x / 2
    }
    
    // Scroll the collection view whenever an item in the menu bar is selected
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(row: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(row: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
    
    func showToastWhenCopied(guidanceType: String, dateString: String) {
        navigationController?.showToast(message: "\(guidanceType) (\(dateString)) \("copied".localOther)!")
    }
    
    func showToastWhenBookmarked(guidanceType: String, dateString: String) {
        navigationController?.showToast(message: "\(guidanceType) (\(dateString)) \("bookmarked".localOther)!")
    }
    
    func showToastWhenUnbookmarked(guidanceType: String, dateString: String) {
        navigationController?.showToast(message: "\(guidanceType) (\(dateString)) \("unbookmarked".localOther)!")
    }
    
    func showToastWithError() {
        navigationController?.showToast(message: "\("unknown_error".localOther)!")
    }
    
    func presentActivityViewController(activityVC: UIActivityViewController) {
        activityVC.popoverPresentationController?.sourceView = navigationController?.view
        navigationController?.present(activityVC, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

