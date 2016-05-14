//
//  MainViewController.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class ChatItem: NSObject {
  var writing = false
  var ownItem = false
}

class StringChatItem: ChatItem {
  var value = ""
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SizeDelegate, EntryViewDelegate {

  private var collectionView: UICollectionView!
  private var entryView: EntryView!
  private var sizingCell: ChatCell!
  private var items = [ChatItem]()
  private var currentTypingItem: StringChatItem?
  private var currentStep = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Heidi"

    let entryHeight = CGFloat(64)

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 20

    self.collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - entryHeight), collectionViewLayout: layout)
    self.collectionView!.registerClass(ChatCell.self, forCellWithReuseIdentifier: "chatCell")
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.alwaysBounceVertical = true
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.collectionView)

    self.sizingCell = ChatCell(frame: CGRectMake(0, 0, self.view.frame.width, 0))


    self.entryView = EntryView(frame: CGRect(x: 0, y: self.view.frame.height - entryHeight, width: self.view.frame.width, height: entryHeight))
    self.entryView.delegate = self
    self.view.addSubview(self.entryView)

    self.delay(1) {
      self.nextStep()
    }
  }

  private func nextStep() {
    if (self.currentStep == 0) {
      self.addMessage("Hello! My name is Heidi.\nI can help you find the perfect place to have a meal, drinks or to party.", showTyping: true)
    } else if (self.currentStep == 1) {
      self.addMessage("What are you looking for?", showTyping: true)
    } else if (self.currentStep == 2) {
      self.entryView.updateOptions(["🍔 Food", "🍻 Drinks", "🎉 Party"], alternativeEntry: nil)
    } else if (self.currentStep == 3) {

    }

    self.currentStep += 1
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = self.items[indexPath.row]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("chatCell", forIndexPath: indexPath) as! ChatCell
    cell.item = item as! StringChatItem
    cell.sizeDelegate = self
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let item = self.items[indexPath.row]
    self.sizingCell.item = item as! StringChatItem
    return self.sizingCell.sizeThatFits(CGSizeMake(self.view.frame.width, 0))
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)

  }

  func subviewDidChangeSize(view: UIView) {
    if let ip = self.collectionView.indexPathForCell(view as! UICollectionViewCell) {
      self.delay(0.01) {
        self.collectionView.reloadItemsAtIndexPaths([ip])
      }
    }
  }

  private func addMessage(message: String, showTyping: Bool, ownItem: Bool = false) {
    let item = StringChatItem()
    item.value = message
    item.writing = showTyping
    item.ownItem = ownItem
    self.items.append(item)
    let indexPath = NSIndexPath(forRow: self.items.count - 1, inSection: 0)
    self.collectionView.insertItemsAtIndexPaths([indexPath])
    self.currentTypingItem = item

    if (showTyping) {
      self.delay(1.6) {
        self.disableTyping(indexPath)
      }
    } else {
      self.delay(0.2) {
        self.nextStep()
      }
    }
  }

  func disableTyping(indexPath: NSIndexPath) {
    self.currentTypingItem!.writing = false
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! ChatCell
    cell.reloadData()
    self.delay(0.2) {
      self.nextStep()
    }
  }

  func entryViewEnteredText(text: String) {

  }

  func entryViewSelectedAnswer(index: Int, value: String) {
    self.entryView.updateOptions([], alternativeEntry: nil)
    self.addMessage(value, showTyping: false, ownItem: true)
    self.nextStep()
  }
}