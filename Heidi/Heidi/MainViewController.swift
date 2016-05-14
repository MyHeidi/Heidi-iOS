//
//  MainViewController.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import LKAlertController
import UberRides
import CoreLocation
import Alamofire

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
  private var nextAnswers = [Answer]()
  private var finished = false

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Heidi"

    self.loadNextQuestion()

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


    NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
      if (self.finished) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(ud.integerForKey("demoStep") + 1, forKey: "demoStep")
        self.currentStep = 0
        self.entryView.updateOptions([], alternativeEntry: nil)
        self.items.removeAll()
        self.collectionView.reloadData()

        self.loadNextQuestion()
      }
      self.finished = false
    }
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

  typealias AddMessageCompletion = () -> ()
  private func addMessage(message: String, showTyping: Bool, ownItem: Bool = false, completion: AddMessageCompletion? = nil) {
    let item = StringChatItem()
    item.value = message
    item.writing = showTyping
    item.ownItem = ownItem
    self.items.append(item)
    let indexPath = NSIndexPath(forRow: self.items.count - 1, inSection: 0)
    self.collectionView.insertItemsAtIndexPaths([indexPath])
    self.currentTypingItem = item

    self.currentStep += 1

    if (showTyping) {
      self.delay(1.6) {
        self.disableTyping(indexPath, completion: completion)
      }
    } else {
      self.delay(0.2) {
        self.showAnswers()
        completion?()
      }
    }
  }

  func disableTyping(indexPath: NSIndexPath, completion: AddMessageCompletion?) {
    self.currentTypingItem!.writing = false
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! ChatCell
    cell.reloadData()
    self.delay(0.2) {
      self.showAnswers()
      completion?()
    }
  }

  private func showAnswers() {
    self.entryView.updateOptions(self.nextAnswers.map{$0.answer}, alternativeEntry: nil)
  }

  func entryViewEnteredText(text: String) {

  }

  func entryViewSelectedAnswer(index: Int, value: String) {
    let a = self.nextAnswers[index]
    if (a.action == "route") {
      self.nextAnswers.removeAll()
      self.entryView.updateOptions([], alternativeEntry: nil)
      self.addMessage(value, showTyping: false, ownItem: true) {
        self.nextAnswers = [Answer(answer: "🚗 Uber", "uber"), Answer(answer: "🗺 Navigate", "nav"), Answer(answer: "🚎 Bus", "bus")]
        for l in self.nextAnswers {
          l.location = a.location
        }
        self.addMessage("How do you want to get there?", showTyping: true)
      }
    } else if (a.action == "uber") {
      self.addMessage(value, showTyping: false, ownItem: true, completion: { 
        self.openUber(a.location!)
        let na = Answer(answer: "✅ Done", "done")
        self.nextAnswers = [na]
        self.showAnswers()
      })
    } else if (a.action == "nav") {
      self.addMessage(value, showTyping: false, ownItem: true, completion: {
        UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?center=\(a.location!.latitude),\(a.location!.longitude)&zoom=14")!)
        let na = Answer(answer: "✅ Done", "done")
        self.nextAnswers = [na]
        self.showAnswers()
      })
    } else if (a.action == "done") {
      self.showEndMessage()
    }

//    self.openUber()
//    self.entryView.updateOptions([], alternativeEntry: nil)
//    self.addMessage(value, showTyping: false, ownItem: true)
//    self.loadNextQuestion()
  }

  private func showEndMessage() {
    self.addMessage("See you again soon! 🇨🇭", showTyping: false)
    self.nextAnswers.removeAll()
    self.entryView.updateOptions([], alternativeEntry: nil)
    self.finished = true
  }
}

// shake gesture
extension MainViewController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.becomeFirstResponder()
  }

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!) {
    if (event.subtype == UIEventSubtype.MotionShake) {
      Alert(title: "Reset?").addAction("Cancel").addAction("Yes", style: .Default, preferredAction: true, handler: { (action: UIAlertAction!) in
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "demoStep")
        self.currentStep = 0
        self.entryView.updateOptions([], alternativeEntry: nil)
        self.items.removeAll()
        self.collectionView.reloadData()
        self.delay(0.1) {
          self.loadNextQuestion()
        }
      }).show()
    }
  }
}


// Uber
extension MainViewController: RideRequestViewControllerDelegate {
  private func openUber(location: CLLocationCoordinate2D) {
    let loginManager = LoginManager(accessTokenIdentifier: "Heidi")
    if let token = TokenManager.fetchToken() {
      self.uberAuthenticated(token.tokenString!, location: location)
    } else {
      loginManager.login(requestedScopes:[.RideWidgets], presentingViewController: self, completion: { accessToken, error in
        if (accessToken == nil) {
          return
        }
        TokenManager.saveToken(accessToken!)
        self.uberAuthenticated(accessToken!.tokenString!, location: location)
      })
    }
  }

  private func uberAuthenticated(token: String, location: CLLocationCoordinate2D) {
    let loginManager = LoginManager(accessTokenIdentifier: "Heidi")
    let parameters = RideParametersBuilder().setPickupLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)).build()
    let rideRequestViewController = RideRequestViewController(rideParameters: parameters, loginManager: loginManager)
    rideRequestViewController.delegate = self
    self.navigationController?.pushViewController(rideRequestViewController, animated: true)
  }

  func rideRequestViewController(rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
    let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .Unknown
    print(error)
  }
}


// Data loading
extension MainViewController {
  private func loadAction() {
    Alamofire.request(.POST, "http://dev.heidi.wx.rs/update_location", parameters: ["lat":"51.153662", "lng":"-0.182063"]).responseJSON { (response: Response<AnyObject, NSError>) in
      if let action = response.result.value!["action"] {
        if (action! as! String == "notification") {
          print("send local notification")
        }
      }
    }
  }

  private func loadNextQuestion() {
    Alamofire.request(.POST, "http://dev.heidi.wx.rs/get_question", parameters: ["lat":"51.153662", "lng":"-0.182063", "prev_answers":"[]"]).responseJSON { (response: Response<AnyObject, NSError>) in
      print(response.result.value!)
      let answers = response.result.value!["answers"] as! Array<Dictionary<String, AnyObject>>
      self.nextAnswers.removeAll()
      for a in answers {
        let newAnswer = Answer()
        newAnswer.id = a["id"] as! String
        newAnswer.action = a["action"] as! String
        newAnswer.answer = a["answer"] as! String
        if let loc = a["location"] {
          let d = loc as! Dictionary<String,AnyObject>
          newAnswer.location = CLLocationCoordinate2D(latitude: d["lat"]! as! Double, longitude: d["lng"]! as! Double)
        }
        self.nextAnswers.append(newAnswer)
      }
      self.addMessage(response.result.value!["question"] as! String, showTyping: true)
    }
  }
}

