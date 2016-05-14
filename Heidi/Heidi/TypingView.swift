//
//  TypingView.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class TypingView: UIView {

  private var circles = [UIView]()
  private var activeIndex = 0

  override init(frame: CGRect) {
    super.init(frame: frame)

    for i in 0..<3 {
      let c = UIView()
      c.frame = CGRect(x: i * 9, y: 0, width: 6, height: 6)
      c.layer.cornerRadius = c.frame.size.width / 2
      c.backgroundColor = UIColor.lightGrayColor()
      self.circles.append(c)
      self.addSubview(c)
    }

    self.animateStep()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func animateStep() {
    let prevIndex = self.activeIndex
    self.activeIndex += 1
    if (self.activeIndex > 2) {
      self.activeIndex = 0
    }

    let p = self.circles[prevIndex]
    UIView.animateWithDuration(0.35) {
      p.backgroundColor = UIColor.lightGrayColor()
    }

    let n = self.circles[self.activeIndex]
    UIView.animateWithDuration(0.35) {
      n.backgroundColor = UIColor.darkGrayColor()
    }

    self.performSelector("animateStep", withObject: nil, afterDelay: 0.4)
  }
}
