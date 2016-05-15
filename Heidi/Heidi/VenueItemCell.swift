//
//  VenueItemCell.swift
//  Heidi
//
//  Created by Dylan Marriott on 15/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import ImageLoader

class VenueItemCell: UICollectionViewCell {

  var venue: Venue! {
    didSet {
      self.reloadData()
    }
  }

  private let titleLabel = UILabel()
  private let container = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)


    container.frame = CGRect(x: 4, y: 0, width: self.frame.width - 8, height: self.frame.height - 8)
    container.backgroundColor = UIColor.darkGrayColor()
    container.layer.cornerRadius = 6
    container.clipsToBounds = true
    container.contentMode = .ScaleAspectFill
    self.addSubview(container)

    titleLabel.frame = CGRect(x: 5, y: 5, width: self.frame.width - 10, height: 0)
    titleLabel.font = UIFont.boldSystemFontOfSize(12)
    titleLabel.textAlignment = .Center
    titleLabel.numberOfLines = 0
    titleLabel.textColor = UIColor.whiteColor()
    self.addSubview(titleLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reloadData() {
    self.titleLabel.text = self.venue.name
    if let url = self.venue.image_url {
      self.container.load(NSURL(string: url)!)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.titleLabel.sizeToFit()
    self.titleLabel.frame.origin = CGPoint(x: self.frame.width / 2 - self.titleLabel.frame.width / 2, y: self.frame.height - 12 - self.titleLabel.frame.height)
    self.titleLabel.frame = CGRectIntegral(self.titleLabel.frame)
  }
}