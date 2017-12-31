import UIKit
import Firebase

protocol BookmarkControllerDelegate: class {
    func reassignBookmarks(communicator: DropDownCommunicator)
}

class BookmarkController: BaseController, BookmarkCellDelegate {
    var delegate: BookmarkControllerDelegate?
    var encouragementCell: BookmarkEncouragementCell?
    var goshoCell: BookmarkGoshoCell?
    
    static let darkColor = UIColor.rgb(red: 0, green: 47, blue: 63)
    
    override lazy var menuBar: MenuBar = {
        let mb = MenuBar(selectedColor: BookmarkController.darkColor, deselectedColor: UIColor.rgb(red: 0, green: 159, blue: 175), horizontalBarColor: BookmarkController.darkColor)
        mb.delegate = self
        return mb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        changeMenuBarColor()
        navTitleLabel.textColor = BookmarkController.darkColor
    }
    
    func getGuidanceModel(guidanceType: GuidanceHelper) -> [GuidanceModel] {
        var bookmarkDates: [String]
        if guidanceType == .BookmarkEncouragement {
            bookmarkDates = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? dropDownCommunicator.bookmarkDEeng! : dropDownCommunicator.bookmarkDEchi!
        } else {
            bookmarkDates = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? dropDownCommunicator.bookmarkDGeng! : dropDownCommunicator.bookmarkDGchi!
        }
        return GuidanceBuilder.sharedInstance.buildGuidanceBookmark(guidanceType: guidanceType, bookmarkedDates: bookmarkDates)
    }
    
    private func setupBackButton() {
        // Setup custom navigation behavior and back button layout
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "Icon-Back"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc private func handleBackButton() {
        changeStatusBarColor(color: UIColor.rgb(red: 33, green: 66, blue: 93))
        changeNavBarColor(color: UIColor.rgb(red: 45, green: 93, blue: 130))
        delegate?.reassignBookmarks(communicator: dropDownCommunicator)
        navigationController?.popViewController(animated: true)
    }
    
    func changeStatusBarColor(color: UIColor) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            appDelegate.statusBarView.backgroundColor = color
        }, completion: nil)
    }
    
    func changeNavBarColor(color: UIColor) {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.navigationController?.navigationBar.barTintColor = color
        }, completion: nil)
    }
    
    private func changeMenuBarColor() {
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.menuBar.collectionView.backgroundColor = UIColor.rgb(red: 77, green: 208, blue: 225)
        }, completion: nil)
    }
    
    override func reloadBookmarkCollectionView(guidanceType: GuidanceHelper) {
        let cell = collectionView?.visibleCells.first
        
        if guidanceType == .BookmarkEncouragement {
            let mCell = cell as! BookmarkEncouragementCell
            mCell.collectionView.reloadData()
        } else if guidanceType == .BookmarkGosho {
            let mCell = cell as! BookmarkGoshoCell
            mCell.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: encouragementCellId, for: indexPath)
            encouragementCell = cell as? BookmarkEncouragementCell
            encouragementCell?.delegate = self
            encouragementCell?.guidanceController = self
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: goshoCellId, for: indexPath)
            goshoCell = cell as? BookmarkGoshoCell
            goshoCell?.delegate = self
            goshoCell?.guidanceController = self
        }
        
        return cell
    }
}

