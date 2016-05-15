//
//  FLEViewController.swift
//  Heidi
//
//  Created by Dylan Marriott on 15/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import paper_onboarding

class FLEViewController: UIViewController, PaperOnboardingDataSource {

  override func viewDidLoad() {
    super.viewDidLoad()

    let onboarding = PaperOnboarding(itemsCount: 3, dataSource: self)
    onboarding.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(onboarding)

    // add constratins
    for attribute: NSLayoutAttribute in [.Left, .Right, .Top, .Bottom] {
      let constraint = NSLayoutConstraint(item: onboarding,
                                          attribute: attribute,
                                          relatedBy: .Equal,
                                          toItem: view,
                                          attribute: attribute,
                                          multiplier: 1,
                                          constant: 0)
      view.addConstraint(constraint)
    }

    let button = UIButton(type: .Custom)
    button.setTitle("Get Started", forState: .Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.titleLabel!.font = UIFont.boldSystemFontOfSize(22)
    button.titleLabel!.textAlignment = .Center
    button.frame = CGRect(x: self.view.frame.width / 2 - 80, y: 60, width: 160, height: 30)
    button.addTarget(self, action: #selector(FLEViewController.actionNext), forControlEvents: .TouchUpInside)
    self.view.addSubview(button)
  }

  func onboardingItemAtIndex(index: Int) -> OnboardingItemInfo {
    return [
      ("BIG_IMAGE1", "Travel", "Heidi knows when you have travelled somewhere new.\n\nLet her help you!", "plane", UIColor(red:0.388,  green:0.549,  blue:0.722, alpha:1)),
      ("BIG_IMAGE2", "Dining", "Heidi uses the Yelp API to find great places to eat.\n\nGive it a try!", "dining", UIColor(red:0.396,  green:0.675,  blue:0.714, alpha:1)),
      ("BIG_IMAGE2", "Search", "Thanks to HPE Haven OnDemand,\nHeidi can do text and image analysis.\n\nIt's amazing!", "search", UIColor(red:0.612,  green:0.580,  blue:0.761, alpha:1)),
      ][index]
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  func actionNext() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fleShown")
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    ad.showMainApp()
  }
}
