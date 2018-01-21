import UIKit
import FirebaseAuthUI

class EmailPasswordVerificationViewController: FUIPasswordVerificationViewController, UITextFieldDelegate {
    var mEmail: String?
    var passwordClearButton: UIButton?
    
    let backgroundView: UIImageView = {
        let image = UIImage(named: "bg_login.jpg")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let passwordLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.text = "password".localOther
        return view
    }()
    
    let passwordTextField: UITextField = {
        let view = UITextField()
        view.textColor = UIColor.rgb(red: 255, green: 170, blue: 0)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.clearButtonMode = .whileEditing
        view.isSecureTextEntry = true
        view.placeholder = "enter_password".localOther
        return view
    }()
    
    let subTitleTextView: UITextView = {
        let view = UITextView()
        view.text = "password_verification_title".localOther
        view.textColor = UIColor.white
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let subContentTextView: UITextView = {
        let view = UITextView()
        view.textColor = UIColor.white
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 13)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let forgotPasswordLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.text = "trouble_signing_in".localOther
        view.font = UIFont.systemFont(ofSize: 13)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackAndNextButton()
        setupSubContentTextField()
        setupPasswordTextField()
        setupForgotPasswordTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "sign_in_title".localOther
        handlePasswordTextDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        setupBackgroundView()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordTextField.becomeFirstResponder()
        passwordTextField.underlined()
    }
    
    private func setupBackAndNextButton() {
        let newBackButton = UIBarButtonItem(title: "back".localOther, style: .plain, target: self, action: #selector(handleBackButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let newNextButton = UIBarButtonItem(title: "next".localOther, style: .plain, target: self, action: #selector(handleNextButton))
        self.navigationItem.rightBarButtonItem = newNextButton
    }
    
    private func setupSubContentTextField() {
        guard let email = mEmail else { return }
        subContentTextView.text = "\("password_verification_body1".localOther) \(email) \("password_verification_body2".localOther)"
    }
    
    private func setupForgotPasswordTextField() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleForgotPassword))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleForgotPassword() {
        self.forgotPassword()
    }
    
    private func setupPasswordTextField() {
        passwordClearButton = passwordTextField.getClearButton(with: UIImage(named: "clear_button")!)
        passwordTextField.addTarget(self, action: #selector(handlePasswordTextDidChange), for: .editingChanged)
        passwordTextField.delegate = self
    }
    
    @objc private func handlePasswordTextDidChange() {
        if let password = passwordTextField.text {
            if password == "" {
                passwordTextField.rightView = nil
            } else {
                passwordTextField.rightView = passwordClearButton
                passwordTextField.rightViewMode = .whileEditing
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = !password.isEmpty
            self.didChangePassword(password)
        }
    }
    
    private func setupViews() {
        view.addSubview(subTitleTextView)
        view.addSubview(subContentTextView)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordLabel)
        
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: subTitleTextView)
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: subContentTextView)
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: passwordLabel, passwordTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: forgotPasswordLabel)
        view.addConstraintsWithFormat(format: "V:|-90-[v0(25)]-16-[v1(42)]-32-[v2(21)]-24-[v3(21)]", views: subTitleTextView, subContentTextView, passwordLabel, forgotPasswordLabel)
        view.addConstraintsWithFormat(format: "V:|-205-[v0(21)]", views: passwordTextField)
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
    
    @objc private func handleNextButton() {
        if let password = passwordTextField.text {
            self.verifyPassword(password)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            handleNextButton()
        }
        return false
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth, email: String?, newCredential: AuthCredential) {
        if let email = email {
            mEmail = email
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI, email: email, newCredential: newCredential)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

