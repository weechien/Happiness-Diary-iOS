import UIKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var statusBarView = UIView()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Create a window with the frame of the screen
        window = UIWindow(frame:UIScreen.main.bounds)
        // Show the window
        window?.makeKeyAndVisible()
        
        // Collection view layout to manage how the cells are displayed
        let layout = UICollectionViewFlowLayout()
        // Set the root view controller
        let guidanceController = GuidanceController(layout: layout)
        window?.rootViewController = UINavigationController(rootViewController: guidanceController)
        
        // Setup the navigation bar
        let navigationController = window?.rootViewController as? UINavigationController
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = BookmarkController.darkColor
        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 45, green: 93, blue: 130)
        // Remove the shadow at the bottom of the navigation bar
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        // Setup the status bar
        application.statusBarStyle = .lightContent
        statusBarView.backgroundColor = UIColor.rgb(red: 33, green: 66, blue: 93)
        window?.addSubview(statusBarView)
        window?.addConstraintsWithFormat(format: "H:|[v0]|", views: statusBarView)
        window?.addConstraintsWithFormat(format: "V:|[v0(20)]", views: statusBarView)
        
        setupFirebase(guidanceController: guidanceController)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func setupFirebase(guidanceController: GuidanceController) {
        FirebaseApp.configure()
        
        let ref = Database.database().reference()
        
        Auth.auth().signIn(withEmail: "weechien@live.com", password: "password") { (user, error) in
            if let mUser = user {
                ref.child("users-bookmarks").child(mUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists() {
                        return
                    }
                    guidanceController.dropDownCommunicator.bookmarkDEeng = [String]()
                    guidanceController.dropDownCommunicator.bookmarkDEchi = [String]()
                    guidanceController.dropDownCommunicator.bookmarkDGeng = [String]()
                    guidanceController.dropDownCommunicator.bookmarkDGchi = [String]()
                    
                    for child in snapshot.children {
                        let key = (child as AnyObject).key as String
                        let start = key.index(key.startIndex, offsetBy: 0)
                        let end = key.index(key.startIndex, offsetBy: 6)

                        switch key[Range(start..<end)] {
                            case "DE Eng": guidanceController.dropDownCommunicator.bookmarkDEeng!.append(key)
                            case "DE Chi": guidanceController.dropDownCommunicator.bookmarkDEchi!.append(key)
                            case "DG Eng": guidanceController.dropDownCommunicator.bookmarkDGeng!.append(key)
                            case "DG Chi": guidanceController.dropDownCommunicator.bookmarkDGchi!.append(key)
                            default: break
                        }
                    }
                    
                }, withCancel: { (error) in
                    print(error.localizedDescription)
                })
            } else {
                print("Not signed in")
            }
        }
    }
}

