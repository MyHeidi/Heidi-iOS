//
//  VenuePickerCell.swift
//  Heidi
//
//  Created by Dylan Marriott on 15/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol VenuePickerCellDelegate: class {
  func selectedVenue(venue: Venue)
}

class VenuePickerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  var item: VenuesChatItem! {
    didSet {
      self.reloadData()
    }
  }
  weak var delegate: VenuePickerCellDelegate?
  private var collectionView: UICollectionView!

  override init(frame: CGRect) {
    super.init(frame: frame)

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 20
    layout.scrollDirection = .Horizontal
    
    self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.alwaysBounceHorizontal = true
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(VenueItemCell.self, forCellWithReuseIdentifier: "venueItemCell")
    self.addSubview(self.collectionView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reloadData() {
    self.collectionView.reloadData()
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.item.venues.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("venueItemCell", forIndexPath: indexPath) as! VenueItemCell
    cell.venue = self.item.venues[indexPath.row]
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: 100, height: collectionView.frame.height)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    self.delegate?.selectedVenue(self.item.venues[indexPath.row])
  }
}
