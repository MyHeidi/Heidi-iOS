//
//  DefaultNavigationBar.swift
//  Heidi
//
//  Created by Dylan Marriott on 15/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class DefaultNavigationController: UINavigationController {

  convenience init() {
    self.init(nibName: nil, bundle: nil)
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)
    self.setupDefaultNavbar()
  }

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    self.setupDefaultNavbar()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupDefaultNavbar() {
    self.navigationBar.barTintColor = UIColor(red:0.200,  green:0.651,  blue:0.992, alpha:1)
    self.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}