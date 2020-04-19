//
//  AppDelegate.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
        return true
    }

}

