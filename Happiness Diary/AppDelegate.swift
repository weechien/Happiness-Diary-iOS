import UIKit
import Firebase
import FirebaseAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var statusBarView = UIView()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
                
        // Create a window with the frame ®of the screen
        window = UIWindow(frame: UIScreen.main.bounds)
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
        AppDelegate.setStatusBarColor()
        window?.addSubview(statusBarView)
        window?.addConstraintsWithFormat(format: "H:|[v0]|", views: statusBarView)
        window?.addConstraintsWithFormat(format: "V:|[v0(20)]", views: statusBarView)
        
        return true
    }
    
    static func getDefaultStatusBarColor() -> UIColor {
        return UIColor.rgb(red: 33, green: 66, blue: 93)
    }
    
    static func setStatusBarColor(color: UIColor = getDefaultStatusBarColor()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.statusBarView.backgroundColor = color
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
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
}

