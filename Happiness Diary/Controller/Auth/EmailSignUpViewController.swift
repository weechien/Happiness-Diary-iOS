import UIKit
import FirebaseAuthUI

class EmailSignUpViewController: FUIPasswordSignUpViewController, UITextFieldDelegate, UITextViewDelegate {
    var emailClearButton: UIButton?
    var nameClearButton: UIButton?
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
    
    let nameLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.text = "name".localOther
        view.textAlignment = .left
        return view
    }()
    
    let nameTextField: UITextField = {
        let view = UITextField()
        view.textColor = UIColor.rgb(red: 255, green: 170, blue: 0)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 17)
        view.clearButtonMode = .whileEditing
        view.placeholder = "first_and_last_name".localOther
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
        view.placeholder = "choose_password".localOther
        return view
    }()
    
    let termsTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.font = UIFont.systemFont(ofSize: 13)
        view.tintColor = UIColor.white
        view.isUserInteractionEnabled = true
        view.isSelectable = true
        view.isEditable = false
        view.dataDetectorTypes = UIDataDetectorTypes.link
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackAndSaveButton()
        setupEmailTextField()
        setupNameTextField()
        setupPasswordTextField()
        setupTermsTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "create_account".localOther
        handleEmailTextDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        setupBackgroundView()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
        emailTextField.underlined()
        nameTextField.underlined()
        passwordTextField.underlined()
    }
    
    private func setupBackAndSaveButton() {
        let newBackButton = UIBarButtonItem(title: "back".localOther, style: .plain, target: self, action: #selector(handleBackButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let newSaveButton = UIBarButtonItem(title: "save".localOther, style: .plain, target: self, action: #selector(handleSaveButton))
        self.navigationItem.rightBarButtonItem = newSaveButton
    }
    
    private func setupEmailTextField() {
        emailClearButton = emailTextField.getClearButton(with: UIImage(named: "clear_button")!)
        emailTextField.addTarget(self, action: #selector(handleEmailTextDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    private func setupNameTextField() {
        nameClearButton = nameTextField.getClearButton(with: UIImage(named: "clear_button")!)
        nameTextField.addTarget(self, action: #selector(handleNameTextDidChange), for: .editingChanged)
        nameTextField.delegate = self
    }
    
    private func setupPasswordTextField() {
        passwordClearButton = passwordTextField.getClearButton(with: UIImage(named: "clear_button")!)
        passwordTextField.addTarget(self, action: #selector(handlePasswordTextDidChange), for: .editingChanged)
        passwordTextField.delegate = self
    }
    
    private func setupTermsTextField() {
        let tosUrl = "https://diary-of-happiness.firebaseapp.com/ToS/"
        let privacyUrl = "https://diary-of-happiness.firebaseapp.com/PrivacyPolicy/"

        let attributedString = NSMutableAttributedString(string: "sign_up_terms".localOther)
        let whiteAttribute = [NSAttributedStringKey.foregroundColor : UIColor.rgb(red: 1, green: 188, blue: 213)]
        attributedString.setAttributes(whiteAttribute, range: NSMakeRange(0, attributedString.length))

        let tosAsLink = attributedString.setAsLink(textToFind: "terms_of_service".localOther, linkURL: tosUrl)
        if tosAsLink {
            let privacyAsLink = attributedString.setAsLink(textToFind: "privacy_policy".localOther, linkURL: privacyUrl)
            if privacyAsLink {
                termsTextView.delegate = self
                termsTextView.attributedText = attributedString
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
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
    
    @objc private func handleNameTextDidChange() {
        if let name = nameTextField.text {
            if name == "" {
                nameTextField.rightView = nil
            } else {
                nameTextField.rightView = nameClearButton
                nameTextField.rightViewMode = .whileEditing
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
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = nameTextField.text {
            
            self.navigationItem.rightBarButtonItem?.isEnabled = !email.isEmpty && !password.isEmpty && !name.isEmpty
            self.didChangeEmail(email, orPassword: password, orUserName: name)
        }
    }
    
    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(termsTextView)
        
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: emailLabel, emailTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: nameLabel, nameTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: passwordLabel, passwordTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-16-|", views: termsTextView)

        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-32-[v1(21)]-32-[v2(21)]-24-[v3(42)]", views: emailLabel, nameLabel, passwordLabel, termsTextView)
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-32-[v1(21)]-32-[v2(21)]", views: emailTextField, nameTextField, passwordTextField)
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
    
    @objc private func handleSaveButton() {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = nameTextField.text {
            self.signUp(withEmail: email, andPassword: password, andUsername: name)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            nameTextField.becomeFirstResponder()
        } else if textField == nameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            handleSaveButton()
        }
        
        return false
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth, email: String?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI, email: email)
        
        emailTextField.text = email
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
