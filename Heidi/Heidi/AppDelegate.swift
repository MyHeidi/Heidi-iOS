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
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    let keys = HeidiKeys()
    Configuration.setSandboxEnabled(true)
    Configuration.setClientID(keys.uberClientID())
    Configuration.setCallbackURIString("heidi://test")


    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window?.backgroundColor = UIColor.whiteColor()
    self.window?.makeKeyAndVisible()

    let vc = MainViewController()
    let nv = UINavigationController(rootViewController: vc)
    self.window?.rootViewController = nv


    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    UIApplication.sharedApplication().registerForRemoteNotifications()


    return true
  }

  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let newToken: String = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
    print("got token", newToken)
    Alamofire.request(.POST, "http://dev.heidi.wx.rs/"+newToken, parameters: nil)
  }

  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
  }

  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

    let taskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
    })

    Alamofire.request(.POST, "http://dev.heidi.wx.rs/update_location", parameters: ["lat":"51.153662", "lng":"-0.182063"]).responseJSON { (response: Response<AnyObject, NSError>) in
      if let action = response.result.value!["action"] {
        if (action! as! String == "notification") {
          let notification = UILocalNotification()
          notification.fireDate = NSDate(timeIntervalSinceNow: 1)
          notification.alertBody = response.result.value!["message"]! as? String
          notification.timeZone = NSTimeZone.defaultTimeZone()
          notification.soundName = UILocalNotificationDefaultSoundName
          application.scheduleLocalNotification(notification)
        }
      }

      UIApplication.sharedApplication().endBackgroundTask(taskId)
      completionHandler(.NewData)
    }
  }
}

