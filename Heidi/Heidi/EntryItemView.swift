//
//  EntryItemView.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class EntryItemView: UIView {

  private let bg = UIView()
  private var titleLabel = UILabel()

  init(frame: CGRect, title: String) {
    super.init(frame: frame)

    self.clipsToBounds = true

    self.bg.backgroundColor = UIColor(red:0.200,  green:0.651,  blue:0.992, alpha:1)
    self.addSubview(self.bg)

    self.titleLabel.frame = CGRect(x: 16, y: 12, width: 0, height: 0)
    self.titleLabel.textColor = UIColor.whiteColor()
    self.titleLabel.font = UIFont.systemFontOfSize(14)
    self.titleLabel.text = title
    self.titleLabel.sizeToFit()
    self.bg.addSubview(self.titleLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sizeThatFits(size: CGSize) -> CGSize {
    self.layoutSubviews()
    return self.bg.frame.size
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let width = self.titleLabel.frame.width + 16 + 16
    let height = self.titleLabel.frame.height + 12 * 2
    self.bg.frame = CGRect(x: 0, y: 0, width: width, height: height)

    self.updateCorners()
  }

  private func updateCorners() {
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(roundedRect: self.bg.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.TopRight).union(.BottomLeft), cornerRadii: CGSizeMake(14, 14)).CGPath
    self.bg.layer.mask = maskLayer
  }
}
