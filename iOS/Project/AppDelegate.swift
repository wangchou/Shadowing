//
//  AppDelegate.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit
import Firebase

let rootViewController = AppDelegate.shared.rootViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        IAPHelper.shared.startListening()
        IAPHelper.shared.requsestProducts()
        loadGameExpirationDate()
        if !isEverReceiptProcessed {
            IAPHelper.shared.processReceipt()
        }

        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootContainerViewController()
        window?.makeKeyAndVisible()

        FirebaseApp.configure()
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
        
        return true
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

// https://medium.com/@stasost/ios-root-controller-navigation-3625eedbbff
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootContainerViewController {
        return window!.rootViewController as! RootContainerViewController
    }
}
