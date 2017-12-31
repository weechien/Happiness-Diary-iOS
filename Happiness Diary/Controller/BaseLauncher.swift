import UIKit

class BaseLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    var popupItems: [AnyObject] = {
        return [AnyObject]()
    }()
    
    let blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if let window = UIApplication.shared.keyWindow {
            view.frame = window.frame
        }
        view.alpha = 0
        return view
    }()
    
    func showItems() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissCollectionView(_:))))
            animateIn()
        }
    }
    
    @objc func dismissCollectionView(_ item: AnyObject?) {
        animateCollectionViewOut(item)
    }
    
    // Called after dismissCollectionView
    func dismissCompleted(_ item: AnyObject?) {}
    
    func animateIn() {
        if let window = UIApplication.shared.keyWindow {
            let height: CGFloat = CGFloat(popupItems.count) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    
    func animateCollectionViewOut(_ item: AnyObject?) {
        if let window = UIApplication.shared.keyWindow {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: { (completed) in
                self.dismissCompleted(item)
            })
        }
    }
    
    func animateBlackViewOut(alpha: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = alpha
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popupItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PopupCell
        cell.item = popupItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popupItem = popupItems[indexPath.item]
        dismissCollectionView(popupItem)
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PopupCell.self, forCellWithReuseIdentifier: cellId)
    }
}

