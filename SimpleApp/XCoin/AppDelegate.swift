//
//  AppDelegate.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = TabbarController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

