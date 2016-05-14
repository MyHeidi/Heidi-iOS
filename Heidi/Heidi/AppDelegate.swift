//
//  AppDelegate.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import UIKit
import UberRides

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    Configuration.setSandboxEnabled(true)

    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window?.backgroundColor = UIColor.whiteColor()
    self.window?.makeKeyAndVisible()

    let vc = MainViewController()
    let nv = UINavigationController(rootViewController: vc)
    self.window?.rootViewController = nv

    return true
  }

}

