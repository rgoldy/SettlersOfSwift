//
//  AppDelegate.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/25/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    enum QuickActionDescription: String {
        case NewGame = "com.settlersOfSwift.newGame"
        case loadGame = "com.settlersOfSwift.loadGame"
        case joinGame = "com.settlersOfSwift.joinGame"
    }
    
    var window: UIWindow?
    var networkManager: NetworkConnection!

//    func loadScreenForShortcut(_ shortcut: UIApplicationShortcutItem) -> Bool {
//        //  set up views for shortcut association
//        return true
//    }
    
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//        let shortcutProcessed = loadScreenForShortcut(shortcutItem)
//        completionHandler(shortcutProcessed)
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        networkManager = NetworkConnection()
//        if let shortcut = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
//            let _ = loadScreenForShortcut(shortcut)
//            return false
//        } else { return true }
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

