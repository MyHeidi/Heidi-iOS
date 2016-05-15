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
  }

  func onboardingItemAtIndex(index: Int) -> OnboardingItemInfo {
    return [
      ("BIG_IMAGE1", "Travel", "Heidi helps you find your hotel and keep your travel documents in one place.", "IconName1", UIColor(red:0.388,  green:0.549,  blue:0.722, alpha:1)),
      ("BIG_IMAGE2", "Dining", "Description text", "IconName2", UIColor(red:0.396,  green:0.675,  blue:0.714, alpha:1)),
      ("BIG_IMAGE2", "Search", "Description text", "IconName2", UIColor(red:0.612,  green:0.580,  blue:0.761, alpha:1)),
      ][index]
  }
}
