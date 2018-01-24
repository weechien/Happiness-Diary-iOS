import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class LoginController: UIViewController, FUIAuthDelegate, VerifyEmailViewControllerDelegate {
    static let GUEST_LOGIN = "GUEST_LOGIN"
    let authUI = FUIAuth.defaultAuthUI()
    
    let launcherImage: UIImageView = {
        let image = UIImage(named: "bg_login_bird.jpg")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let signInButton: CustomLoginButton = {
        let view = CustomLoginButton()
        view.setTitle("sign_in_sign_up".localOther, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        view.backgroundColor = UIColor.rgb(red: 77, green: 77, blue: 255)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let guestButton: CustomLoginButton = {
        let view = CustomLoginButton()
        view.setTitle("continue_as_guest".localOther, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        view.backgroundColor = UIColor.rgb(red: 189, green: 32, blue: 49)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static func isGuest() -> Bool {
        let guestPref = UserDefaults.standard
        if guestPref.object(forKey: LoginController.GUEST_LOGIN) == nil {
            guestPref.set(false, forKey: LoginController.GUEST_LOGIN)
            return false
        }
        return guestPref.object(forKey: LoginController.GUEST_LOGIN) as! Bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFirebaseAuthUI()
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            print(error.debugDescription)
        } else if let user = user {
            manageUserProvider(user)
        }
    }
    
    private func manageUserProvider(_ user: User) {
        for provider in user.providerData {
            switch provider.providerID {
            case "google.com":
                self.dismiss(animated: false, completion: nil)
                break
            case "facebook.com":
                self.dismiss(animated: false, completion: nil)
                break
            case "password":
                verifyEmail(user)
                break
            default: break
            }
        }
    }
    
    private func verifyEmail(_ user: User) {
        user.reload { error in
            if error != nil {
                self.navigationController?.showDefaultAlert(message: "unknown_error".localOther)
            }
            if user.isEmailVerified {
                self.dismiss(animated: false, completion: nil)
            } else {
                let verifyEmailViewController = VerifyEmailViewController()
                verifyEmailViewController.delegate = self
                verifyEmailViewController.mEmail = user.email
                let navController = UINavigationController(rootViewController: verifyEmailViewController)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func verificationComplete() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func setupFirebaseAuthUI() {
        authUI?.delegate = self
        authUI?.customStringsBundle = Bundle.main
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth()]
        authUI?.providers = providers
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthPickerViewController(nibName: nil, bundle: Bundle.main, authUI: authUI)
    }
    
    func emailEntryViewController(forAuthUI authUI: FUIAuth) -> FUIEmailEntryViewController {
        return EmailEntryViewController(nibName: nil, bundle: Bundle.main, authUI: authUI)
    }
    
    func passwordSignUpViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
        return EmailSignUpViewController(nibName: nil, bundle: Bundle.main, authUI: authUI, email: email)
    }
    
    func passwordSignInViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
        return EmailSignInViewController(nibName: nil, bundle: Bundle.main, authUI: authUI, email: email)
    }
    
    func passwordRecoveryViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
        return EmailPasswordRecoveryViewController(nibName: nil, bundle: Bundle.main, authUI: authUI, email: email)
    }
    
    func passwordVerificationViewController(forAuthUI authUI: FUIAuth, email: String, newCredential: AuthCredential) -> FUIPasswordVerificationViewController {
        return EmailPasswordVerificationViewController(nibName: nil, bundle: Bundle.main, authUI: authUI, email: email, newCredential: newCredential)
    }
    
    @objc private func handleSignInButton() {
        let authViewController = self.authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    @objc private func handleGuestButton() {
        UserDefaults.standard.set(true, forKey: LoginController.GUEST_LOGIN)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        addLauncherImage()
        addGuestButton()
        addSignInButton()
        AppDelegate.setStatusBarColor(color: UIColor(white: 1, alpha: 0))
    }
    
    private func addLauncherImage() {
        view.addSubview(launcherImage)
        launcherImage.frame = UIScreen.main.bounds
        launcherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launcherImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func addGuestButton() {
        view.addSubview(guestButton)
        guestButton.addTarget(self, action: #selector(handleGuestButton), for: .touchUpInside)
        guestButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        guestButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        guestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guestButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height * -0.18).isActive = true
    }
    
    private func addSignInButton() {
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(handleSignInButton), for: .touchUpInside)
        signInButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: guestButton.topAnchor, constant: -25).isActive = true
    }
}
