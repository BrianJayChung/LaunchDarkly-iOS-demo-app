import UIKit
import LaunchDarkly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let mobileKey = "mob-8e3e03d8-355e-432b-a000-e2a15a12d7e6"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpLDClient()
        UITabBar.appearance().tintColor = .red
        UINavigationBar.appearance().tintColor = .red
        UINavigationBar.appearance().isTranslucent = false
//        UINavigationBar.appearance().barTintColor = UIColor(red: 0.054902, green: 0.0980392, blue: 0.196078, alpha: 1.0)
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Override point for customization after application launch.
        return true
    }
    
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
//    var orientationLock = UIInterfaceOrientationMask.all
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return self.orientationLock
//    }
//
//    struct AppUtility {
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
//            if let delegate = UIApplication.shared.delegate as? AppDelegate {
//                delegate.orientationLock = orientation
//            }
//        }
//
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
//            self.lockOrientation(orientation)
//            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
//        }
//    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func setUpLDClient() {
        let userBuilder = LDUserBuilder()
        userBuilder.key = "test@email.com"

        let config = LDConfig(mobileKey: mobileKey)
        LDClient.sharedInstance().start(config, with: userBuilder)
    }

    
}

