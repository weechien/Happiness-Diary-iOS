import UIKit
import FirebaseAuthUI

class AuthPickerViewController: FUIAuthPickerViewController {
    
    let imageView: UIImageView = {
        let image = UIImage(named: "bg_login_bird.jpg")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insertSubview(imageView, at: 0)
        setupCancelButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "welcome".localOther
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setImageViewFrame()
    }
    
    private func setupCancelButton() {
        let newCancelButton = UIBarButtonItem(title: "cancel".localOther, style: .plain, target: self, action: #selector(handleCancelButton))
        self.navigationItem.leftBarButtonItem = newCancelButton
    }
    
    @objc func handleCancelButton() {
        self.cancelAuthorization()
    }
    
    private func setImageViewFrame() {
        if #available(iOS 11.0, *) {
            let safeAreaLayoutHeight = view.safeAreaLayoutGuide.layoutFrame.height
            let bottomLayoutHeight = view.frame.maxY - view.safeAreaLayoutGuide.layoutFrame.maxY
            let axisY = view.frame.height - safeAreaLayoutHeight - bottomLayoutHeight
            imageView.frame = CGRect(x: 0, y: axisY, width: view.frame.width, height: safeAreaLayoutHeight + bottomLayoutHeight)
        } else {
            let topLayoutGuideHeight = topLayoutGuide.length
            let mHeight = view.frame.height - topLayoutGuideHeight
            imageView.frame = CGRect(x: 0, y: topLayoutGuideHeight, width: view.frame.width, height: mHeight)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
