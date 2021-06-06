//
//  AppDelegate.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = ImageListViewController.make()

        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}
