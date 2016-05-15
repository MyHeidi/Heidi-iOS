//
//  PhotoChatCell.swift
//  Heidi
//
//  Created by Dylan Marriott on 15/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class PhotoChatCell: UICollectionViewCell {

  var item: PhotoChatItem! {
    didSet {
      self.reloadData()
    }
  }

  weak var sizeDelegate: SizeDelegate?
  private let bg = UIView()
  private let iv = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.clipsToBounds = true

    self.addSubview(self.bg)
    self.bg.addSubview(self.iv)
    self.iv.contentMode = .ScaleAspectFill
    self.iv.clipsToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func reloadData() {
    self.iv.image = self.item.image
    self.bg.backgroundColor = self.item.ownItem ? UIColor(red:0.200,  green:0.651,  blue:0.992, alpha:1) : UIColor(white: 0.90, alpha: 1.0)
    self.layoutSubviews()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let width:CGFloat = min(self.item.image.size.width, 160)
    let height:CGFloat = min(self.item.image.size.height, 160)
    self.bg.frame = CGRect(x: (self.item!.ownItem ? self.frame.width - width - 20 : 20), y: 0, width: width, height: height)
    self.iv.frame = CGRect(x: 8, y: 8, width: self.bg.frame.width - 16, height: self.bg.frame.height - 16)

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

  override func sizeThatFits(size: CGSize) -> CGSize {
    self.layoutSubviews()
    return CGSize(width: size.width, height: self.bg.frame.height)
  }
}