//
//  AppDelegate.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import UIKit
import UberRides
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    let keys = HeidiKeys()
    Configuration.setSandboxEnabled(true)
    Configuration.setClientID(keys.uberClientID)


    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window?.backgroundColor = UIColor.whiteColor()
    self.window?.makeKeyAndVisible()

    let vc = MainViewController()
    let nv = UINavigationController(rootViewController: vc)
    self.window?.rootViewController = nv

    return true
  }

}

