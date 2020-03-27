//
//  AppDelegate.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        } catch {
            print("Error launching Realm in AppDelegate, \(error)")
        }
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

