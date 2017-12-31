import UIKit

class PopupCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            iconImage.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
        }
    }
    
    var item: AnyObject? {
        didSet {
            itemDidSet(item: item)
        }
    }
    
    let nameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let iconImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(iconImage)
        
        addConstraintsWithFormat(format: "H:|-16-[v0(30)]-[v1]|", views: iconImage, nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImage)
        
        addConstraint(NSLayoutConstraint(item: iconImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func itemDidSet(item: AnyObject?) {
        if let mItem = item as? SettingPopupModel {
            assignSettingDataToView(item: mItem)
        } else if let mItem = item as? DropdownPopupModel {
            assignDropdownDataToView(item: mItem)
        }
    }
    
    private func assignSettingDataToView(item: SettingPopupModel) {
        nameLabel.text = item.name.rawValue.localOther
        iconImage.image = UIImage(named: item.imageName)?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = UIColor.darkGray
    }
    
    private func assignDropdownDataToView(item: DropdownPopupModel) {
        nameLabel.text = item.name.rawValue.localOther
        iconImage.image = UIImage(named: item.imageName)?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = UIColor.darkGray
    }
}
