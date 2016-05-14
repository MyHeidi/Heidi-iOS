//
//  LabelExtension.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

  func sizeForWidth(width: CGFloat, attributed: Bool = false) -> CGSize {
    if ((self.text == nil && self.attributedText == nil) || self.font == nil) {
      return CGSizeZero
    }

    if (attributed) {
      let rect = self.attributedText?.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin,  NSStringDrawingOptions.UsesFontLeading], context: nil)
      return rect!.size
    } else {
      let constraintRect = CGSize(width: width, height: CGFloat.max)
      let boundingBox = self.text!.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font], context: nil)
      return boundingBox.size
    }
  }
  
}