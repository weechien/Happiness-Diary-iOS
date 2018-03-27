import UIKit
import Firebase
import FirebaseStorageUI
import SDWebImage

// Cell of the collection view within the encouragement cell / gosho cell
class SubGuidanceCell: BaseCell {

    let sourceViewHeight: CGFloat = 20
    var sourceViewHeightConstraint: NSLayoutConstraint?
    var imageAspectRatio: CGFloat = 0
    var parallaxOffset: CGFloat = 0 {
        didSet {
            imageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: parallaxOffset).isActive = true
        }
    }
    var guidance: GuidanceModel? {
        didSet {
            if let image = guidance?.image,
                let date = guidance?.date,
                let content = guidance?.content,
                let source = guidance?.source,
                let color = guidance?.backgroundColor {
                print(image)
                
                // Get a reference to the storage service using the default Firebase App
                let ref = Storage.storage().reference().child(image)
                imageView.sd_setImage(with: ref, placeholderImage: nil, completion: nil)
                
                updateImageViewConstraints()

                if imageView.image == nil {
                    activityIndicatorView.startAnimating()
                }

                self.backgroundColor = color
                
                dateView.text = date
                dateView.backgroundColor = color
                
                contentsView.text = content
                contentsView.backgroundColor = color
                contentsView.addLineSpacing()
                
                sourceView.text = source
                sourceView.backgroundColor = color
                
                updateSourceViewHeight(source: source)
            }
        }
    }
    
    let imageViewWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    // The image view displaying pictures with a parallax effect
    lazy var imageView: ImageViewObserveDidSet = {
        let view = ImageViewObserveDidSet()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Label for the date
    let dateView: UILabel = {
        let view = UILabel()
        return view
    }()
    
    // Drop down menu for the cell
    let dropDownView: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "ic_drop_down_grey"), for: UIControlState.normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Content of the guidance
    let contentsView: UITextView = {
        let view = UITextView()
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isEditable = false
        view.isSelectable = false
        return view
    }()
    
    // Author of the guidance
    let sourceView: UITextView = {
        let view = UITextView()
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isUserInteractionEnabled = false
        view.textAlignment = .right
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        // Add the views to the cell object
        addSubview(imageViewWrapper)
        imageViewWrapper.addSubview(imageView)
        addSubview(dateView)
        addSubview(dropDownView)
        addSubview(contentsView)
        addSubview(sourceView)
        
        // Add the constraints for the views
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageViewWrapper)
        imageViewWrapper.addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "H:|-16-[v0(150)]", views: dateView)
        addConstraintsWithFormat(format: "H:[v0(40)]-16-|", views: dropDownView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: contentsView)
        addConstraintsWithFormat(format: "H:|-48-[v0]-16-|", views: sourceView)
        // Set the height of the mainImageView to 30% of the cell's height
        addConstraintsWithFormat(format: "V:|[v0(m0)]-24-[v1(30)]", views: imageViewWrapper, dateView, metric: addMetricDictionary(frame.size.height * 0.3))
        
        contentsView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 16).isActive = true
        contentsView.bottomAnchor.constraint(equalTo: sourceView.topAnchor, constant: -16).isActive = true
        
        sourceView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        sourceViewHeightConstraint = sourceView.heightAnchor.constraint(equalToConstant: sourceViewHeight)
        sourceViewHeightConstraint?.isActive = true
        
        imageViewWrapper.addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
        
        imageViewWrapper.addSubview(activityIndicatorView)
        activityIndicatorView.frame = imageViewWrapper.frame
        activityIndicatorView.centerXAnchor.constraint(equalTo: imageViewWrapper.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: imageViewWrapper.centerYAnchor).isActive = true
        
        // Top constraint of the dropDownView
        addConstraint(NSLayoutConstraint(item: dropDownView, attribute: .top, relatedBy: .equal, toItem: imageViewWrapper, attribute: .bottom, multiplier: 1, constant: 16))
        // Height constraint of the dropDownView
        addConstraint(NSLayoutConstraint(item: dropDownView, attribute: .height, relatedBy: .equal, toItem: dropDownView, attribute: .width, multiplier: 1, constant: 0))
    }
    
    // Set the width and height of the image view to be the same as the image
    func updateImageViewConstraints() {
        let imageWidth = imageView.image?.size.width ?? 0
        let imageHeight = imageView.image?.size.height ?? 0
        
        imageAspectRatio = imageHeight / imageWidth
        imageView.widthAnchor.constraint(equalToConstant: imageWidth)
        imageView.heightAnchor.constraint(equalToConstant: imageHeight)
        imageView.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("sourceView height: \(sourceView.frame.height)")
        print("sourceView width: \(sourceView.frame.width)")
        print("frame.width: \(frame.width)")
    }
    
    private func updateSourceViewHeight(source: String) {
        let sourceTextHeight = source.height(withConstrainedWidth: frame.width - 48 - 16, font: sourceView.font!)
        
        if sourceTextHeight > (sourceViewHeightConstraint?.constant)! {
            sourceViewHeightConstraint?.isActive = false
            sourceViewHeightConstraint?.constant = sourceTextHeight + 6
            sourceViewHeightConstraint?.isActive = true
        } else {
            sourceViewHeightConstraint?.isActive = false
            sourceViewHeightConstraint?.constant = sourceViewHeight
            sourceViewHeightConstraint?.isActive = true
        }
    }
    
    func updateParallaxOffset(offsetDistance: CGFloat, maxDistance: CGFloat, scrollDirection: UICollectionViewScrollDirection) {
        // Get the maximum movable distance of the image
        let heightDifference = (imageView.frame.width * imageAspectRatio) - imageView.frame.height
        let totalMovableDistance: CGFloat = heightDifference > 0 ? heightDifference / 2 : 0

        // Calculate the image position and apply the parallax factor
        let finalY = (offsetDistance / maxDistance) * totalMovableDistance
        
        // Now we have final position, set the offset of the frame of the background iamge
        let frame = imageView.bounds
        let offsetFrame = frame.offsetBy(dx: 0, dy: finalY)
        imageView.frame = offsetFrame
    }
}










