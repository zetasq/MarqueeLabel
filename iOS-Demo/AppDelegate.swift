//
//  AppDelegate.swift
//  iOS-Demo
//
//  Created by Zhu Shengqi on 18/12/2017.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let mainWindow = UIWindow()
    self.window = mainWindow
    
    mainWindow.rootViewController = RootViewController()
    mainWindow.makeKeyAndVisible()
    
    return true
  }
  
}

