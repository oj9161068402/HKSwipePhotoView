//
//  AppDelegate.swift
//  HKSwipePhotoView
//
//  Created by nge0131 on 2023/9/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /**
         入口: PhotoCleanerVC.swift
         */
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: PhotoCleanerVC())
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        
        return true
    }

}

