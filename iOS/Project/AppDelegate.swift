//
//  AppDelegate.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import Firebase
import UIKit

let rootViewController = AppDelegate.shared.rootViewController
var launchT = getNow()

func pt(_ key: String) {
    #if DEBUG
    let secs = String(format: "%.4f", getNow() - launchT)
    print("\(secs)s   \(key)")
    #endif
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        launchT = getNow()

        IAPHelper.shared.startListening()
        IAPHelper.shared.requsestProducts()
        loadGameExpirationDate()
        if !isEverReceiptProcessed {
            IAPHelper.shared.processReceipt()
        }

//        #if DEBUG
//            Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
//        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootContainerViewController()
        window?.makeKeyAndVisible()

        FirebaseApp.configure()

        #if targetEnvironment(macCatalyst)
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .forEach { windowScene in
                    let height = windowScene.screen.nativeBounds.height / 1.5 - 64
                    let width = height * 8 / 15
                    print(windowScene.screen.nativeBounds, windowScene.screen.scale)
                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: width, height: height)
                    windowScene.sizeRestrictions?.maximumSize = CGSize(width: width, height: height)
                    screen = CGRect(x: 0, y: 0, width: width, height: height)
                }
        #endif

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print(#function)

        #if targetEnvironment(macCatalyst)
            postCommand(.pause)
        #endif
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(#function)

        // iOS request permission alert will trigger applicationWillResignActive
        // so need to put forceStop at DidEnterBackground
        #if !targetEnvironment(macCatalyst)
            postCommand(.forceStopGame)
            if let messenger = UIApplication.getPresentedViewController() as? Messenger {
                messenger.dismiss(animated: false)
            }
        #endif
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print(#function)
        DispatchQueue.main.async { [weak self] in
            self?.rootViewController.updateWhenEnterForeground()
        }
        VoiceDefaults.fixVoicesAvailablity()
        #if !targetEnvironment(macCatalyst)
            SpeechEngine.shared.fixRecordingIndicator()
        #else
            postCommand(.resume)
        #endif
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(#function)
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(#function)
    }
}

// https://medium.com/@stasost/ios-root-controller-navigation-3625eedbbff
// swiftlint:disable force_cast
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var rootViewController: RootContainerViewController {
        return window!.rootViewController as! RootContainerViewController
    }
}

// swiftlint:enable force_cast
