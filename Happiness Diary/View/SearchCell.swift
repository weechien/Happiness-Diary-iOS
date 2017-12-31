import UIKit

class SearchCell: UITableViewCell {
    
    var guidance: GuidanceModel? {
        didSet {
            dateView.attributedText = guidance?.getDate()
            contentsView.attributedText = guidance?.getContent()
            sourceView.attributedText = guidance?.getSource()
        }
    }
    
    // Label for the date
    let dateView: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "BeyondTheMountains", size: 15)

        return view
    }()
    
    let watermarkView: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.lightGray
        view.textAlignment = .right
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    // Content of the guidance
    let contentsView: UITextView = {
        let view = UITextView()
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isUserInteractionEnabled = false
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()
    
    // Author of the guidance
    let sourceView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isUserInteractionEnabled = false
        view.textAlignment = .right
        return view
    }()
        
    func setupViews() {
        // Add the views to the cell object
        addSubview(dateView)
        addSubview(watermarkView)
        addSubview(contentsView)
        addSubview(sourceView)
        
        // Add the constraints for the views
        addConstraintsWithFormat(format: "H:|-16-[v0(150)]", views: dateView)
        addConstraintsWithFormat(format: "H:[v0(150)]-16-|", views: watermarkView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: contentsView)
        addConstraintsWithFormat(format: "H:|-48-[v0]-16-|", views: sourceView)
        // Set the height of the mainImageView to 30% of the cell's height
        addConstraintsWithFormat(format: "V:|-[v0(25)]-[v1]-[v2(30)]|", views: dateView, contentsView, sourceView)
        
        watermarkView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        watermarkView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
}
