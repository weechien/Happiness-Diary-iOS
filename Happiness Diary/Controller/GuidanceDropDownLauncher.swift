import UIKit
import Firebase
import FirebaseDatabase

protocol GuidanceDropDownLauncherDelegate: class {
    var dropDownCommunicator: DropDownCommunicator { get set }
    
    func showToastWhenCopied(guidanceType: String, dateString: String)
    func showToastWhenBookmarked(guidanceType: String, dateString: String)
    func showToastWhenUnbookmarked(guidanceType: String, dateString: String)
    func showToastWithError()
    func presentActivityViewController(activityVC: UIActivityViewController)
    func reloadBookmarkCollectionView(guidanceType: GuidanceHelper)
}

class GuidanceDropDownLauncher: BaseLauncher {
    weak var delegate: GuidanceDropDownLauncherDelegate?
    var cell: SubGuidanceCell?
    var guidanceType: GuidanceHelper?
    var bookmarkList = [String]()
    var popupItem: DropdownPopupModel?
    var user: User?
    
    lazy var defaultItems: [DropdownPopupModel] = {
        let share = DropdownPopupModel(name: .Share, imageName: "ic_share")
        let copy = DropdownPopupModel(name: .Copy, imageName: "ic_copy")
        let bookmark = DropdownPopupModel(name: .Bookmark, imageName: "ic_guidance_bookmark")
        
        return [share, copy, bookmark]
    }()
    
    lazy var shareItems: [DropdownPopupModel] = {
        let shareImage = DropdownPopupModel(name: .ShareImage, imageName: "ic_image")
        let shareGuidance = DropdownPopupModel(name: .ShareGuidance, imageName: "ic_guidance")
        
        return [shareImage, shareGuidance]
    }()
    
    let activityIndicator : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func showItems() {
        if let mCell = cell?.dateView.text {
            if bookmarkList.contains("\(getGuidanceType()) \(getLanguage()) \(mCell)") {
                defaultItems[2] = DropdownPopupModel(name: .Unbookmark, imageName: "ic_guidance_bookmark")
            } else {
                defaultItems[2] = DropdownPopupModel(name: .Bookmark, imageName: "ic_guidance_bookmark")
            }
        }

        popupItems = defaultItems
        collectionView.reloadData()
        super.showItems()
    }
    
    func passArray(array: inout Array<String>) {
        bookmarkList = array
    }
    
    private func getGuidanceType() -> String {
        guard let guidanceType = guidanceType else { return "" }
        
        switch guidanceType {
        case .Encouragement, .BookmarkEncouragement:
            return "DE"
        case .Gosho, .BookmarkGosho:
            return "DG"
        default:
            return ""
        }
    }
    
    private func getLanguage() -> String {
        return Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? "Eng" : "Chi"
    }
    
    override func dismissCollectionView(_ item: AnyObject?) {
        super.dismissCollectionView(item)
        
        if let mItem = item as? DropdownPopupModel, mItem.name == .Share {
            self.animateBlackViewOut(alpha: 0.5)
        } else {
            self.animateBlackViewOut(alpha: 0)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        popupItem = popupItems[indexPath.item] as? DropdownPopupModel
        
        if let item = popupItem, (item.name == .Bookmark || item.name == .Unbookmark) {
            showActivityIndicator()
            let cells = collectionView.visibleCells as! [PopupCell]
            updateCellAppearance(cells: cells, isEnabled: false)
            let bool = item.name == .Bookmark ? false : true
            updateFirebaseDatabase(remove: bool)
        } else {
            dismissCollectionView(popupItem)
        }
    }
    
    private func updateCellAppearance(cells: [PopupCell], isEnabled: Bool) {
        if isEnabled {
            for cell in cells {
                cell.nameLabel.isEnabled = true
                cell.iconImage.tintColor = UIColor.darkGray
            }
        } else {
            for cell in cells {
                cell.nameLabel.isEnabled = false
                cell.iconImage.tintColor = UIColor.lightGray
            }
        }
    }
    
    private func showActivityIndicator() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            activityIndicator.frame = window.frame
            activityIndicator.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        }
    }
    
    // Called after dismissCollectionView
    override func dismissCompleted(_ item: AnyObject?) {
        super.dismissCompleted(item)
        
        if let setting = item as? DropdownPopupModel {
            switch (setting.name) {
                case .Share: showShareOptions()
                case .ShareImage: shareImage()
                case .ShareGuidance: shareGuidance()
                case .Copy: copyGuidance()
                case .Bookmark: break
                case .Unbookmark: reloadCollectionView()
                case .Cancel: break
            }
        }
    }
    
    private func reloadCollectionView() {
        guard let guidanceType = guidanceType else { return }
        
        switch guidanceType {
        case .BookmarkEncouragement, .BookmarkGosho:
            delegate?.reloadBookmarkCollectionView(guidanceType: guidanceType)
        default:
            return
        }
    }
    
    private func showShareOptions() {
        popupItems = shareItems
        collectionView.reloadData()
        animateIn()
    }
    
    private func shareImage() {
        let image: UIImage? = cell?.imageView.image
        
        if let mImage = image {
            let activityVC = UIActivityViewController(activityItems: [mImage], applicationActivities: nil)
            delegate?.presentActivityViewController(activityVC: activityVC)
        }
    }
    
    private func shareGuidance() {
        let activityVC = UIActivityViewController(activityItems: [getCellGuidance().2], applicationActivities: nil)
        delegate?.presentActivityViewController(activityVC: activityVC)
    }
    
    private func copyGuidance() {
        UIPasteboard.general.string = getCellGuidance().2
        delegate?.showToastWhenCopied(guidanceType: getCellGuidance().0, dateString: getCellGuidance().1)
    }
    
    private func getCellGuidance() -> (String, String, String) {
        let title = guidanceType == .Encouragement ? "daily_encouragement".localOther : "daily_gosho".localOther
        
        if let cellDate = cell?.dateView.text, let cellContent = cell?.contentsView.text, let cellSource = cell?.sourceView.text {
            return ("\(title)", "\(cellDate)", "\(title) \(getSunriseEmoji())\n\(cellDate)\n\n\(cellContent)\n\n\(cellSource)\n\n\("share_promotion1".localOther) \u{1F54A}: \("share_promotion2".localOther)")
        } else {
            return ("", "", "")
        }
    }
    
    private func getSunriseEmoji() -> String {
        let now = Date()
        
        if now >= setTime(hour: 6, minute: 0, second: 0) && now <= setTime(hour: 18, minute: 0, second: 0) {
            return "\u{1F305}"
        } else {
            return "\u{1F304}"
        }
    }
    
    private func setTime(hour: Int, minute: Int, second: Int) -> Date {
        let date = Date()
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return gregorian.date(from: components)!
    }
    
    private func updateFirebaseDatabase(remove: Bool) {
        let ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        if let user = user, let mCell = cell?.dateView.text {
            let key = "\(getGuidanceType()) \(getLanguage()) \(mCell)"
            let userRef = ref.child("users-bookmarks").child(user.uid)
            if remove == true {
                userRef.child(key).removeValue(completionBlock: unbookmarkFirebaseCompleted)
            } else {
                userRef.child(key).setValue(true, withCompletionBlock: bookmarkFirebaseCompleted)
            }
        }
    }
    
    private func bookmarkFirebaseCompleted(error: Error?, ref: DatabaseReference) {
        manageCompletion(error: error, unbookmark: false)
    }
    
    private func unbookmarkFirebaseCompleted(error: Error?, ref: DatabaseReference) {
        manageCompletion(error: error, unbookmark: true)
    }
    
    private func manageCompletion(error: Error?, unbookmark: Bool) {
        if error != nil {
            self.delegate?.showToastWithError()
            dismissCollectionView(popupItem)
            return
        }
        if let mCell = cell?.dateView.text {
            let key = "\(getGuidanceType()) \(getLanguage()) \(mCell)"
            
            if unbookmark, let index = bookmarkList.index(of: key) {
                bookmarkList.remove(at: index)
                delegate?.showToastWhenUnbookmarked(guidanceType: getCellGuidance().0, dateString: getCellGuidance().1)
            } else {
                bookmarkList.append(key)
                delegate?.showToastWhenBookmarked(guidanceType: getCellGuidance().0, dateString: getCellGuidance().1)
            }
            assignBookmarkListBack()
            let cells = collectionView.visibleCells as! [PopupCell]
            updateCellAppearance(cells: cells, isEnabled: true)
            dismissCollectionView(popupItem)
            activityIndicator.stopAnimating()
        }
    }
    
    private func assignBookmarkListBack() {
        guard let delegateCommunicator = delegate?.dropDownCommunicator else {
            return
        }
        if guidanceType == .Encouragement || guidanceType == .BookmarkEncouragement {
            if Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue {
                delegateCommunicator.bookmarkDEeng = bookmarkList
            } else {
                delegateCommunicator.bookmarkDEchi = bookmarkList
            }
        } else if guidanceType == .Gosho || guidanceType == .BookmarkGosho {
            if Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue {
                delegateCommunicator.bookmarkDGeng = bookmarkList
            } else {
                delegateCommunicator.bookmarkDGchi = bookmarkList
            }
        }
    }
}
