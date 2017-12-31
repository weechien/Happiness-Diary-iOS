import UIKit

protocol MenuBarDelegate: class {
    func scrollToMenuIndex(menuIndex: Int)
}

// Menu bar which is located right below the navigation bar
class MenuBar: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var delegate: MenuBarDelegate?
    var selectedColor: UIColor
    var deselectedColor: UIColor
    var horizontalBarColor: UIColor
    var horizontalBarLeftConstraint: NSLayoutConstraint?
    
    // Setup the collection view within the menu bar
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.rgb(red: 45, green: 93, blue: 130)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    static let fontSize:CGFloat = 17
    let cellId = "cellId"
    // String array for the cells
    var longNames = ["daily_encouragement".localOther, "daily_gosho".localOther]
    var shortNames = ["encouragement".localOther, "gosho".localOther]
    var firstCell: MenuCell?
    
    init(selectedColor: UIColor, deselectedColor: UIColor, horizontalBarColor: UIColor) {
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        self.horizontalBarColor = horizontalBarColor
        
        super.init(frame: .zero)
        
        setupCollectionView()
        setupHorizontalBar()
    }
    
    func setupCollectionView() {
        // Register the cell of the collection view
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        // Add the collection view
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        // Select the first cell when the application is launched
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .top)
    }
    
    func setupHorizontalBar() {
        let horizontalBarView = UIView()
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        horizontalBarView.backgroundColor = horizontalBarColor
        addSubview(horizontalBarView)
        
        horizontalBarLeftConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftConstraint?.isActive = true
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Scroll the collection view in the guidance controller
        delegate?.scrollToMenuIndex(menuIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        cell.selectedColor = selectedColor
        cell.deselectedColor = deselectedColor
        
        // Compare the width of the cell and the text
        let size = CGSize(width: .greatestFiniteMagnitude, height: frame.height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedRect = NSString(string: longNames[indexPath.item]).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: MenuBar.fontSize)], context: nil)
        
        // Use the short name as the title if the long name doesn't fit the label
        if indexPath.item == 0 {
            firstCell = cell
            if estimatedRect.size.width > (frame.width / 2) {
                cell.label.text = shortNames[indexPath.item]
            } else {
                cell.label.text = longNames[indexPath.item]
            }
        } else {
            if let firstCell = firstCell {
                if firstCell.label.text == shortNames[0] {
                    cell.label.text = shortNames[indexPath.item]
                } else {
                    cell.label.text = longNames[indexPath.item]
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
    // Spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Cell of the collection view
class MenuCell: BaseCell {
    var selectedColor: UIColor = UIColor.white {
        didSet {
            label.textColor = isHighlighted ? selectedColor : deselectedColor
        }
    }
    var deselectedColor: UIColor = UIColor.rgb(red: 33, green: 46, blue: 57) {
        didSet {
            label.textColor = isSelected ? selectedColor : deselectedColor
        }
    }
    
    let label: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: MenuBar.fontSize)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? selectedColor : deselectedColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedColor : deselectedColor
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(label)
        addConstraintsWithFormat(format: "H:|[v0]|", views: label)
        addConstraintsWithFormat(format: "V:|[v0]|", views: label)
    }
}












