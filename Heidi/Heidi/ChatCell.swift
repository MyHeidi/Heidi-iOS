//
//  ChatCell.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell {

  var item: StringChatItem! {
    didSet {
      self.reloadData()
    }
  }

  weak var sizeDelegate: SizeDelegate?

  private let bg = UIView()
  private var typingView: TypingView!
  private var titleLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.clipsToBounds = true

    self.addSubview(self.bg)

    self.typingView = TypingView(frame: CGRect(x: 22, y: 17, width: 24, height: 6))
    self.bg.addSubview(self.typingView)

    self.titleLabel.frame = CGRect(x: 16, y: 12, width: self.frame.width - 124, height: 0)
    self.titleLabel.font = UIFont.systemFontOfSize(14)
    self.titleLabel.numberOfLines = 0
    self.titleLabel.lineBreakMode = .ByWordWrapping
    self.bg.addSubview(self.titleLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sizeThatFits(size: CGSize) -> CGSize {
    return CGSizeMake(size.width, self.bg.frame.height + 0)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let titleSize = self.titleLabel.sizeForWidth(self.frame.width - 124, attributed: false)
    self.titleLabel.frame.size.width = titleSize.width
    self.titleLabel.frame.size.height = titleSize.height

    let width = self.item!.writing ? 68 : titleSize.width + 16 * 2
    let height = self.item!.writing ? 40 : titleSize.height + 12 * 2
    self.bg.frame = CGRect(x: (self.item!.ownItem ? self.frame.width - width - 20 : 20), y: 0, width: width, height: height)

    self.updateCorners()
    self.sizeDelegate?.subviewDidChangeSize(self)
  }

  private func updateCorners() {
    let maskLayer = CAShapeLayer()
    if (self.item.ownItem) {
      maskLayer.path = UIBezierPath(roundedRect: self.bg.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.TopRight).union(.BottomLeft), cornerRadii: CGSizeMake(14, 14)).CGPath
    } else {
      maskLayer.path = UIBezierPath(roundedRect: self.bg.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.TopRight).union(.BottomRight), cornerRadii: CGSizeMake(14, 14)).CGPath
    }
    self.bg.layer.mask = maskLayer
  }

  func reloadData() {
    self.setTitleText(self.item.value)
    self.typingView.hidden = !self.item.writing
    self.titleLabel.hidden = self.item.writing
    self.titleLabel.textAlignment = self.item.ownItem ? .Right : .Left
    self.titleLabel.textColor = self.item.ownItem ? UIColor.whiteColor() : UIColor(white: 0.1, alpha: 1.0)
    self.bg.backgroundColor = self.item.ownItem ? UIColor(red:0.200,  green:0.651,  blue:0.992, alpha:1) : UIColor(white: 0.90, alpha: 1.0)
    self.layoutSubviews()
  }

  private func setTitleText(text: String) {
    //    let titleParagraphStyle = NSMutableParagraphStyle()
    //    titleParagraphStyle.lineSpacing = 3
    //    let titleAttrString = NSMutableAttributedString(string: text)
    //    titleAttrString.addAttribute(NSParagraphStyleAttributeName, value:titleParagraphStyle, range:NSMakeRange(0, titleAttrString.length))
    //    self.titleLabel.attributedText = titleAttrString
    self.titleLabel.text = text
  }
}