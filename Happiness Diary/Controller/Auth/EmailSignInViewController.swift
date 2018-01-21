import UIKit
import FirebaseAuthUI

class EmailSignInViewController: FUIPasswordSignInViewController, UITextFieldDelegate {
    var emailClearButton: UIButton?
    var passwordClearButton: UIButton?
    
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
        
        setupBackAndSignInButton()
        setupEmailTextField()
        setupPasswordTextField()
        setupForgotPasswordLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "sign_in_title".localOther
        handleEmailTextDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        setupBackgroundView()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordTextField.becomeFirstResponder()
        emailTextField.underlined()
        passwordTextField.underlined()
    }
    
    private func setupBackAndSignInButton() {
        let newBackButton = UIBarButtonItem(title: "back".localOther, style: .plain, target: self, action: #selector(handleBackButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let newSignInButton = UIBarButtonItem(title: "sign_in_title".localOther, style: .plain, target: self, action: #selector(handleSignInButton))
        self.navigationItem.rightBarButtonItem = newSignInButton
    }
    
    private func setupEmailTextField() {
        emailClearButton = emailTextField.getClearButton(with: UIImage(named: "clear_button")!)
        emailTextField.addTarget(self, action: #selector(handleEmailTextDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    private func setupPasswordTextField() {
        passwordClearButton = passwordTextField.getClearButton(with: UIImage(named: "clear_button")!)
        passwordTextField.addTarget(self, action: #selector(handlePasswordTextDidChange), for: .editingChanged)
        passwordTextField.delegate = self
    }
    
    private func setupForgotPasswordLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleForgotPassword))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleEmailTextDidChange() {
        if let email = emailTextField.text {
            if email == "" {
                emailTextField.rightView = nil
            } else {
                emailTextField.rightView = emailClearButton
                emailTextField.rightViewMode = .whileEditing
            }
            handleTextFieldValueDidChange()
        }
    }
    
    @objc private func handlePasswordTextDidChange() {
        if let password = passwordTextField.text {
            if password == "" {
                passwordTextField.rightView = nil
            } else {
                passwordTextField.rightView = passwordClearButton
                passwordTextField.rightViewMode = .whileEditing
            }
            handleTextFieldValueDidChange()
        }
    }
    
    private func handleTextFieldValueDidChange() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            self.navigationItem.rightBarButtonItem?.isEnabled = !email.isEmpty && !password.isEmpty
            self.didChangeEmail(email, andPassword: password)
        }
    }
    
    @objc private func handleForgotPassword() {
        if let email = emailTextField.text {
            self.forgotPassword(forEmail: email)
        }
    }
    
    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordLabel)
        
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: emailLabel, emailTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: passwordLabel, passwordTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: forgotPasswordLabel)
        
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-32-[v1(21)]-32-[v2(21)]", views: emailLabel, passwordLabel, forgotPasswordLabel)
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-32-[v1(21)]", views: emailTextField, passwordTextField)
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
    
    @objc private func handleSignInButton() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            self.signIn(withDefaultValue: email, andPassword: password)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            handleSignInButton()
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

