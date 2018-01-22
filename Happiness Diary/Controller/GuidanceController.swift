import UIKit
import Firebase

class GuidanceController: BaseController, SearchControllerDelegate, SettingsLauncherDelegate, BookmarkControllerDelegate {
    var encouragementCell: EncouragementCell?
    var goshoCell: GoshoCell?
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.delegate = self
        return launcher
    }()
    
    lazy var loadingScreen: UIImageView = {
        let image = UIImage(named: "bg_login_bird_blur.jpg")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()
    
    let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFirebaseAuth(isGuestLogin: LoginController.isGuest())
        setupNavBarButtons()
    }
    
    private func setupFirebaseAuth(isGuestLogin: Bool) {
        if isGuestLogin { return }
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                self.dropDownCommunicator.setBookmarkArray(stringArray: nil)
                self.presentLoginController()
            } else if self.dropDownCommunicator.bookmarkDEeng == nil || self.dropDownCommunicator.bookmarkDEchi == nil || self.dropDownCommunicator.bookmarkDGeng == nil || self.dropDownCommunicator.bookmarkDGchi == nil  {
                if self.manageUserProvider(user!) == false { return }
                self.setupLoadingScreen()
                self.loadFirebaseDatabase(user!)
            }
        })
    }
    
    private func manageUserProvider(_ user: User) -> Bool {
        for provider in user.providerData {
            switch provider.providerID {
            case FirebaseProvider.Google.rawValue:
                return true
            case FirebaseProvider.Facebook.rawValue:
                return true
            case FirebaseProvider.Password.rawValue:
                return verifyEmail(user)
            default:
                return false
            }
        }
        return false
    }
    
    private func verifyEmail(_ user: User) -> Bool {
        if !user.isEmailVerified {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            return false
        }
        return true
    }
    
    override func handleNavigationTitleClick() {
        let indexPath = MainGuidanceCell.getIndexPathForToday()
        
        if let encouragementVisibleCells = encouragementCell?.collectionView.visibleCells.first {
            let visibleCellIndexPath = encouragementCell?.collectionView.indexPath(for: encouragementVisibleCells)
            
            if let visibleCellIndexPath = visibleCellIndexPath {
                if indexPath.row - visibleCellIndexPath.row == 1 || indexPath.row - visibleCellIndexPath.row == -1 {
                    encouragementCell?.collectionView.scrollToItem(at: indexPath, at: [], animated: true)
                } else {
                    encouragementCell?.collectionView.scrollToItem(at: indexPath, at: [], animated: false)
                }
            }
        }
        if let goshoVisibleCells = goshoCell?.collectionView.visibleCells.first {
            let visibleCellIndexPath = goshoCell?.collectionView.indexPath(for: goshoVisibleCells)
            
            if let visibleCellIndexPath = visibleCellIndexPath {
                if indexPath.row - visibleCellIndexPath.row == 1 || indexPath.row - visibleCellIndexPath.row == -1 {
                    goshoCell?.collectionView.scrollToItem(at: indexPath, at: [], animated: true)
                } else {
                    goshoCell?.collectionView.scrollToItem(at: indexPath, at: [], animated: false)
                }
            }
        }
        
    }
    
    func presentLoginController() {
        let loginController = LoginController()
        self.present(loginController, animated: false, completion: nil)
    }
    
    private func setupLoadingScreen() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(loadingScreen)
            window.addConstraintsWithFormat(format: "H:|[v0]|", views: loadingScreen)
            window.addConstraintsWithFormat(format: "V:|[v0]|", views: loadingScreen)
            
            window.addSubview(activityIndicator)
            window.addConstraintsWithFormat(format: "H:|[v0]|", views: activityIndicator)
            window.addConstraintsWithFormat(format: "V:|[v0]|", views: activityIndicator)
            activityIndicator.startAnimating()
        }
    }
    
    private func loadFirebaseDatabase(_ user: User) {
        let ref = Database.database().reference()
        
        ref.child("users-bookmarks").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.dropDownCommunicator.setBookmarkArray(stringArray: [String]())
            
            for child in snapshot.children {
                let key = (child as AnyObject).key as String
                let start = key.index(key.startIndex, offsetBy: 0)
                let end = key.index(key.startIndex, offsetBy: 6)
                
                switch key[Range(start..<end)] {
                case "DE Eng": self.dropDownCommunicator.bookmarkDEeng!.append(key)
                case "DE Chi": self.dropDownCommunicator.bookmarkDEchi!.append(key)
                case "DG Eng": self.dropDownCommunicator.bookmarkDGeng!.append(key)
                case "DG Chi": self.dropDownCommunicator.bookmarkDGchi!.append(key)
                default: break
                }
            }
            self.dismissLoadingScreen()
        })
    }
    
    private func dismissLoadingScreen() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if let window = UIApplication.shared.keyWindow {
                self.loadingScreen.frame = CGRect(x: 0, y: -window.frame.height, width: self.loadingScreen.frame.width, height: self.loadingScreen.frame.height)
                self.activityIndicator.stopAnimating()
            }
        }, completion: { Bool in
            self.loadingScreen.removeFromSuperview()
            self.activityIndicator.removeFromSuperview()
        })
    }
    
    override func checkIsCardColorEnabled() {
        super.checkIsCardColorEnabled()
        
        if isCardColorEnabled != SettingsViewController.isCardColorEnabled() {
            isCardColorEnabled = SettingsViewController.isCardColorEnabled()
            encouragementCell?.collectionView.reloadData()
            goshoCell?.collectionView.reloadData()
        }
    }

    func searchItemSelected(row: Int, guidance: GuidanceHelper) {
        let indexPath = IndexPath(row: row, section: 0)
        let guidance: MainGuidanceCell? = guidance == .Encouragement ? encouragementCell : goshoCell
        guidance?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        guidance?.collectionView.reloadData()
    }
    
    // Setup the buttons of the navigation bar
    private func setupNavBarButtons() {
        let searchImage = UIImage(named: "ic_search")?.withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        let bookmarkImage = UIImage(named: "ic_guidance_bookmark")?.withRenderingMode(.alwaysOriginal)
        let bookmarkButton = UIBarButtonItem(image: bookmarkImage, style: .plain, target: self, action: #selector(handleBookmark))
        
        let overflowImage = UIImage(named: "ic_overflow")?.withRenderingMode(.alwaysOriginal)
        let overflowButton = UIBarButtonItem(image: overflowImage, style: .plain, target: self, action: #selector(handleOverflow))
        
        navigationItem.rightBarButtonItems = LoginController.isGuest() ? [overflowButton, searchButton] : [overflowButton, bookmarkButton, searchButton]
    }
    
    // Manage the overflow button on click
    @objc private func handleOverflow() {
        settingsLauncher.showItems()
    }
    
    // Navigate to a new view when the setting's items are clicked
    func showControllerForSetting(_ setting: SettingPopupModel) {
        if setting.name == .About {
            let aboutViewController = AboutViewController()
            aboutViewController.navigationItem.title = setting.name.rawValue
            
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            navigationController?.pushViewController(aboutViewController, animated: true)
            
        } else if setting.name == .Settings {
            let settingsViewController = SettingsViewController()
            settingsViewController.navigationItem.title = setting.name.rawValue
            
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
    
    // Refresh the text on language change
    func refreshLanguage() {
        setupNavigationBar()
        
        menuBar.longNames = ["daily_encouragement".localOther, "daily_gosho".localOther]
        menuBar.shortNames = ["encouragement".localOther, "gosho".localOther]
        
        let indexPath = menuBar.collectionView.indexPathsForSelectedItems?.first
        
        menuBar.collectionView.reloadData()
        menuBar.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        
        encouragementCell?.refreshCell()
        goshoCell?.refreshCell()
        
        collectionView?.reloadData()
    }
    
    // Manage the bookmark button on click
    @objc private func handleBookmark() {
        let layout = UICollectionViewFlowLayout()
        let bookmarkController = BookmarkController(layout: layout, firstCell: BookmarkEncouragementCell.self, secondCell: BookmarkGoshoCell.self)
        bookmarkController.changeStatusBarColor(color: UIColor.rgb(red: 0, green: 159, blue: 175))
        GuidanceBuilder.sharedInstance.sortBookmark(communicator: dropDownCommunicator)
        bookmarkController.dropDownCommunicator = dropDownCommunicator
        bookmarkController.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 77, green: 208, blue: 225)
        navigationController?.pushViewController(bookmarkController, animated: true)
    }
    
    func reassignBookmarks(communicator: DropDownCommunicator) {
        dropDownCommunicator = communicator
    }
    
    // Manage the search button on click
    @objc private func handleSearch() {
        let indexPath = menuBar.collectionView.indexPathsForSelectedItems?.first
        
        let searchController = SearchController()
        searchController.delegate = self
        searchController.mainIndexPath = indexPath?.row
        
        searchController.navigationItem.title = "search".localOther
        searchController.view.backgroundColor = UIColor.white
        
        animateViewControllerIn(controller: searchController, transitionPosition: kCATransitionFromTop)
    }
    
    func animateViewControllerIn(controller: UIViewController, transitionPosition: String) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = transitionPosition
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationController?.pushViewController(controller, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: encouragementCellId, for: indexPath)
            encouragementCell = cell as? EncouragementCell
            encouragementCell?.guidanceController = self
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: goshoCellId, for: indexPath)
            goshoCell = cell as? GoshoCell
            goshoCell?.guidanceController = self
        }
        return cell
    }
}
