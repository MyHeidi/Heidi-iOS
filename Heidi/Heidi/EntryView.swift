//
//  EntryView.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol EntryViewDelegate: class {
  func entryViewSelectedAnswer(index: Int, value: String)
  func entryViewEnteredText(text: String)
}

class EntryView: UIView {

  weak var delegate: EntryViewDelegate?
  private var itemViews = [EntryItemView]()
  private var options = [String]()
  private var keyboardButton = UIButton(type: .Custom)

  override init(frame: CGRect) {
    super.init(frame: frame)

    let d = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
    d.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
    self.addSubview(d)

    self.keyboardButton.frame = CGRect(x: self.frame.width - 55, y: 0, width: 48, height: 64)
    self.keyboardButton.setImage(UIImage(named: "keyboard")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    self.keyboardButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
    self.addSubview(self.keyboardButton)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateOptions(options: [String], alternativeEntry: String?) {
    self.options = options
    for i in self.itemViews {
      UIView.animateWithDuration(0.1, animations: {
        i.alpha = 0.0
        }, completion: { (finished: Bool) in
          i.removeFromSuperview()
      })
    }
    self.itemViews.removeAll()

    for (index, title) in options.enumerate() {
      let item = EntryItemView(frame: CGRectMake(0, 0, 200, 0), title: title)
      item.layoutSubviews()
      item.alpha = 0.0
      item.tag = index
      item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedOnItem:"))
      self.addSubview(item)
      self.itemViews.append(item)

      UIView.animateWithDuration(0.2, animations: {
        item.alpha = 1.0
      })
    }

    self.layoutSubviews()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let space = self.frame.width - 48

    var totalWidth = CGFloat(0)
    for item in self.itemViews {
      totalWidth += item.sizeThatFits(CGSizeZero).width
    }

    let spacing = (space - totalWidth) / CGFloat(self.itemViews.count + 1)
    var x = spacing
    for item in self.itemViews {
      let size = item.sizeThatFits(CGSizeZero)
      item.frame = CGRect(x: x, y: 12, width: size.width, height: size.height)
      x += size.width + spacing
    }
  }

  func tappedOnItem(gesture: UITapGestureRecognizer) {
    let index = gesture.view!.tag
    self.delegate?.entryViewSelectedAnswer(index, value: self.options[index])
  }
}