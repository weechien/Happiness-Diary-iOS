import UIKit

protocol SearchControllerDelegate: class {
    func searchItemSelected(row: Int, guidance: GuidanceHelper)
}

class SearchController: UITableViewController, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    weak var delegate: SearchControllerDelegate?
    var mainIndexPath: Int?
    var searchIndex: Int?
    var searchController = CustomSearchController(searchResultsController: nil)
    lazy var guidance: [GuidanceModel] = GuidanceBuilder.sharedInstance.buildGuidance(helper: self.mainIndexPath == 0 ? .Encouragement : .Gosho)
    var filteredGuidance = [GuidanceModel]()
    let cellId = "cellId"

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredGuidance = guidance.filter({( guidance : GuidanceModel) -> Bool in
            if let combinedString = guidance.combinedString {
                if combinedString.string.lowercased().contains(searchText.lowercased()) {
                    guidance.combinedString = highlightSearchResult(searchString: searchText, combinedString: combinedString.string)
                } else {
                    // Remove attributes
                    let string = NSMutableAttributedString(string: combinedString.string)
                    string.removeAttribute(NSAttributedStringKey.foregroundColor, range: NSMakeRange(0, combinedString.string.count))
                    guidance.combinedString = string
                }
                
                return combinedString.string.lowercased().contains(searchText.lowercased())
            }
            
            return false
        })
        
        tableView.reloadData()
    }
    
    func highlightSearchResult(searchString: String, combinedString: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: combinedString)
        let pattern = searchString.lowercased()
        let range: NSRange = NSMakeRange(0, combinedString.characters.count)
        
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        
        regex.enumerateMatches(in: combinedString.lowercased(), options: NSRegularExpression.MatchingOptions(), range: range) { (textCheckingResult, matchingFlags, stop) -> Void in
            let subRange = textCheckingResult?.range
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.rgb(red: 1, green: 188, blue: 213), range: subRange!)
        }
        
        return attributedString
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SearchCell
        let mGuidance: GuidanceModel
        
        if isFiltering() {
            mGuidance = filteredGuidance[indexPath.row]
        } else {
            mGuidance = guidance[indexPath.row]
        }
        
        cell.guidance = mGuidance
        cell.watermarkView.text = mainIndexPath == 0 ? "encouragement".localOther : "gosho".localOther
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFiltering() {
            let filteredContent = filteredGuidance[indexPath.row].getContent()
            
            return filteredContent.height(withConstrainedWidth: view.frame.width - 32) + 89
        } else {
            let content = guidance[indexPath.row].getContent()
            
            return content.height(withConstrainedWidth: view.frame.width - 32) + 89
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SearchCell
        for (index, value) in guidance.enumerated() {
            if cell?.dateView.text == value.date {
                searchIndex = index
                dismissSearchController(callbackAfterDismiss: true)
                break
            }
        }
    }
    
    private func callSearchItemSelected() {
        if let selectedIndex = searchIndex {
            delegate?.searchItemSelected(row: selectedIndex, guidance: self.mainIndexPath == 0 ? .Encouragement : .Gosho)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredGuidance.count
        }
        
        return guidance.count
    }
    
    @objc func handleBackButton(sender: AnyObject) {
        dismissSearchController(callbackAfterDismiss: false)
    }
    
    private func dismissSearchController(callbackAfterDismiss: Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        navigationController?.view.layer.add(transition, forKey:kCATransition)
        
        if callbackAfterDismiss {
            navigationController?.popViewController(animated: false, completion: callSearchItemSelected)
        } else {
            navigationController?.popViewController(animated: false)
        }
    }

    @objc func handleCancelButton(sender: AnyObject) {
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search".localOther
        searchController.searchBar.tintColor = view.tintColor
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let cancelButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedStringKey : Any], for: [])
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        tableView.register(SearchCell.self, forCellReuseIdentifier: cellId)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate =  self

        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        
        // Setup custom navigation behavior and back button layout
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "Icon-Back"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackButton(sender:)), for: .touchUpInside)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        // Setup custom navigation behavior and back button layout
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("cancel".localOther, for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancelButton(sender:)), for: .touchUpInside)
        cancelButton.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
