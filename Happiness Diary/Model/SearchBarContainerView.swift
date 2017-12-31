import UIKit

class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        addSubview(searchBar)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}

class CustomSearchBar: UISearchBar {
    
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        super.setShowsCancelButton(false, animated: false)
    }
}

class CustomSearchController: UISearchController {
    
    lazy var _searchBar: CustomSearchBar = {
        [unowned self] in
        let customSearchBar = CustomSearchBar(frame: CGRect.zero)
        return customSearchBar
        }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}
