import UIKit
import Firebase

protocol VerifyEmailViewControllerDelegate: class {
    func verificationComplete()
}

class VerifyEmailViewController: UIViewController {
    var delegate: VerifyEmailViewControllerDelegate?
    var handle: AuthStateDidChangeListenerHandle?
    var mEmail: String? {
        didSet {
            emailTextField.text = mEmail
        }
    }
    
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
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let sendVerificationLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.rgb(red: 1, green: 188, blue: 213)
        view.text = "didnt_get_email".localOther
        view.font = UIFont.systemFont(ofSize: 13)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelAndSignInButton()
        setupSendVerificationLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "verify_email".localOther
        setupFirebaseAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    override func viewDidLayoutSubviews() {
        setupBackgroundView()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.underlined()
    }
    
    private func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                self.handleCancelButton()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.checkDatabaseForEmailVerificationSent(user)
                })
            }
        })
    }
    
    private func checkDatabaseForEmailVerificationSent(_ user: User?) {
        guard let userId = user?.uid, let email = self.mEmail else { return }
        
        let databaseRef = Database.database().reference()
        let databaseChild = databaseRef.child("users").child(userId).child("emailVerSent")
        
        databaseChild.observeSingleEvent(of: .value, with: { snapshot in
            if !(snapshot.value as! Bool) {
                self.sendEmailVerification(user, databaseChild, email)
            }
            databaseChild.removeAllObservers()
        }, withCancel: { error in
            self.navigationController?.showDefaultAlert(message: "unknown_error".localOther)
        })
    }
    
    private func sendEmailVerification(_ user: User?, _ databaseChild: DatabaseReference, _ email: String) {
        user?.sendEmailVerification(completion: { error in
            if error != nil {
                self.navigationController?.showDefaultAlert(message: "unknown_error".localOther)
            }
            databaseChild.setValue(true)
            self.navigationController?.showDefaultAlert(message:
                "\("resend_verification_succeeded".localOther) \(email)\n\n\("email_not_verified".localOther)")
        })
    }
    
    private func setupCancelAndSignInButton() {
        let newCancelButton = UIBarButtonItem(title: "cancel".localOther, style: .plain, target: self, action: #selector(handleCancelButton))
        self.navigationItem.leftBarButtonItem = newCancelButton
        
        let newCompleteButton = UIBarButtonItem(title: "complete".localOther, style: .plain, target: self, action: #selector(handleCompleteButton))
        self.navigationItem.rightBarButtonItem = newCompleteButton
    }
    
    private func setupSendVerificationLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleResendVerification))
        sendVerificationLabel.addGestureRecognizer(tapGesture)
    }
    
    // Open an alert dialog to confirm resending verification email
    @objc private func handleResendVerification() {
        let action1 = UIAlertAction(title: "cancel".localOther, style: .default, handler: nil)
        let action2 = UIAlertAction(title: "ok_message".localOther, style: .default, handler: handleActionResendVerification)

        self.navigationController?.showAlert(title: nil, message: "resend_verification_email".localOther, actions: action1, action2)
    }
    
    // Send the verification email
    private func handleActionResendVerification(_ action: UIAlertAction) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if error != nil {
                self.navigationController?.showDefaultAlert(message: "resend_verification_failed".localOther)
            } else {
                guard let email = self.mEmail else { return }
                self.navigationController?.showDefaultAlert(message: "\("resend_verification_succeeded".localOther) \(email)")
            }
        })
    }
    
    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendVerificationLabel)
        
        view.addConstraintsWithFormat(format: "H:|-24-[v0(80)]-16-[v1]-16-|", views: emailLabel, emailTextField)
        view.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: sendVerificationLabel)
        
        view.addConstraintsWithFormat(format: "V:|-120-[v0(21)]-32-[v1(21)]", views: emailLabel, sendVerificationLabel)
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
    
    @objc private func handleCancelButton() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func handleCompleteButton() {
        guard let user = Auth.auth().currentUser else { return }

        user.reload { error in
            if error != nil {
                self.navigationController?.showDefaultAlert(message: "unknown_error".localOther)
            }
            if user.isEmailVerified {
                self.dismiss(animated: true, completion: {
                    self.delegate?.verificationComplete()
                })
            } else {
                self.navigationController?.showDefaultAlert(message: "email_not_verified".localOther)
            }
        }
    }
}



