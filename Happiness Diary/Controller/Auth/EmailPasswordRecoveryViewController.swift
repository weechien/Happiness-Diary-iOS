import UIKit
import FirebaseAuthUI

class EmailPasswordRecoveryViewController: FUIPasswordRecoveryViewController, UITextFieldDelegate {
    var emailClearButton: UIButton?
    
    let backgroundView: UIImageView = {
        let image = UIImage(named: "bg_login.jpg")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let emailLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.text = "email".localOther
        view.textAlignment = .center
        return view
    }()
    
    let emailTextField: UITextField = {
        let view = UITextField()
        view.textColor = UIColor.rgb(red: 255, green: 170, blue: 0)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.clearButtonMode = .whileEditing
        view.placeholder = "enter_your_email".localOther
        return view
    }()
    
    let infoTextView: UITextView = {
        let view = UITextView()
        view.text = "email_recovery_info".localOther
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 13)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackAndSendButton()
        setupEmailTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "recover_password".localOther
        handleEmailTextDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        setupBackgroundView()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.becomeFirstResponder()
        emailTextField.underlined()
    }
    
    private func setupBackAndSendButton() {
        let newBackButton = UIBarButtonItem(title: "back".localOther, style: .plain, target: self, action: #selector(handleBackButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let newSendButton = UIBarButtonItem(title: "send".localOther, style: .plain, target: self, action: #selector(handleSendButton))
        self.navigationItem.rightBarButtonItem = newSendButton
    }
    
    private func setupEmailTextField() {
        emailClearButton = emailTextField.getClearButton(with: UIImage(named: "clear_button")!)
        emailTextField.addTarget(self, action: #selector(handleEmailTextDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    @objc private func handleEmailTextDidChange() {
        if let email = emailTextField.text {
            if email == "" {
                emailTextField.rightView = nil
            } else {
                emailTextField.rightView = emailClearButton
                emailTextField.rightViewMode = .whileEditing
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = !email.isEmpty
            self.didChangeEmail(email)
        }
    }
    
    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(infoTextView)
        
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: emailLabel, emailTextField)
        view.addConstraintsWithFormat(format: "H:|-40-[v0]-16-|", views: infoTextView)
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-24-[v1(42)]", views: emailLabel, infoTextView)
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]", views: emailTextField)
    }
    
    private func setupBackgroundView() {
        view.addSubview(backgroundView)
        
        if #available(iOS 11.0, *) {
            let safeAreaLayoutHeight = view.safeAreaLayoutGuide.layoutFrame.height
            let bottomLayoutHeight = view.frame.maxY - view.safeAreaLayoutGuide.layoutFrame.maxY
            let axisY = view.frame.height - safeAreaLayoutHeight - bottomLayoutHeight
            backgroundView.frame = CGRect(x: 0, y: axisY, width: view.frame.width, height: safeAreaLayoutHeight + bottomLayoutHeight)
        } else {
            let topLayoutGuideHeight = topLayoutGuide.length
            let mHeight = view.frame.height - topLayoutGuideHeight
            backgroundView.frame = CGRect(x: 0, y: topLayoutGuideHeight, width: view.frame.width, height: mHeight)
        }
    }
    
    @objc private func handleBackButton() {
        self.onBack()
    }
    
    @objc private func handleSendButton() {
        if let email = emailTextField.text {
            self.recoverEmail(email)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField, let email = textField.text {
            self.recoverEmail(email)
        }
        return false
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth, email: String?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI, email: email)
        
        emailTextField.text = email
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

