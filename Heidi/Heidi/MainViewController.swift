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
import SafariServices

class ChatItem: NSObject {
  var writing = false
  var ownItem = false
}

class StringChatItem: ChatItem {
  var value = ""
}

class VenuesChatItem: ChatItem {
  var venues = [Venue]()
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SizeDelegate, EntryViewDelegate {

  private var collectionView: UICollectionView!
  private var entryView: EntryView!
  private var sizingCell: ChatCell!
  private var items = [ChatItem]()
  private var currentTypingItem: StringChatItem?
  private var currentStep = 0
  private var demoStep = 1
  private var nextAnswers = [Answer]()
  private var finished = false
  private var history = [[String:String]]()
  private var lastQuestion = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Heidi"

    self.loadNextQuestion()

    let entryHeight = CGFloat(64)

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 20

    self.collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - entryHeight), collectionViewLayout: layout)
    self.collectionView!.registerClass(ChatCell.self, forCellWithReuseIdentifier: "chatCell")
    self.collectionView!.registerClass(VenuePickerCell.self, forCellWithReuseIdentifier: "venuePickerCell")
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 10, 0)
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 10, 0)
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
        self.demoStep += 1
        self.currentStep = 0
        self.entryView.updateOptions([], alternativeEntry: nil)
        self.items.removeAll()
        self.collectionView.reloadData()
        self.history.removeAll()

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
    if (item is StringChatItem) {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("chatCell", forIndexPath: indexPath) as! ChatCell
      cell.item = item as! StringChatItem
      cell.sizeDelegate = self
      return cell
    } else if (item is VenuesChatItem) {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("venuePickerCell", forIndexPath: indexPath) as! VenuePickerCell
      cell.item = item as! VenuesChatItem
      cell.delegate = self
      return cell
    }
    return UICollectionViewCell()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let item = self.items[indexPath.row]
    if (item is StringChatItem) {
      self.sizingCell.item = item as! StringChatItem
      return self.sizingCell.sizeThatFits(CGSizeMake(self.view.frame.width, 0))
    } else if (item is VenuesChatItem) {
      return CGSizeMake(self.view.frame.width, 100)
    }
    return CGSizeZero
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
    if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? ChatCell {
      cell.reloadData()
    }
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
    } else if (a.action == "question") {
      self.history.append(["question_id":self.lastQuestion, "answer_id":a.id])
      self.nextAnswers.removeAll()
      self.entryView.updateOptions([], alternativeEntry: nil)
      self.addMessage(value, showTyping: false, ownItem: true) {
        self.loadNextQuestion()
      }
    } else if (a.action == "request") {
      self.history.append(["question_id":self.lastQuestion, "answer_id":a.id])
      self.nextAnswers.removeAll()
      self.entryView.updateOptions([], alternativeEntry: nil)
      self.addMessage(value, showTyping: false, ownItem: true) {
        let historyData = try! NSJSONSerialization.dataWithJSONObject(self.history, options: NSJSONWritingOptions.PrettyPrinted)
        Alamofire.request(.POST, "http://dev.heidi.wx.rs"+a.url!, parameters: ["lat":"51.5225996", "lng":"-0.085515", "prev_answers":NSString(data: historyData, encoding: NSUTF8StringEncoding)!]).responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
          if (response.result.value == nil) {
            Alert(title: "Error", message: "Didn't get a valid response from the server.").showOkay()
            return
          }
          if let answer = response.result.value!["answer"] as? String {
            self.addMessage(answer, showTyping: true, ownItem: false) {
              self.showEndMessage()
            }
          }
          if let places = response.result.value!["places"] as? [[String:AnyObject]] {
            var venues = [Venue]()
            for place in places {
              let venue = Venue()
              venue.name = place["name"] as! String
              venue.id = place["id"] as! String
              if (place["image_url"] as? NSNull != NSNull()) {
                venue.image_url = place["image_url"] as? String
              }
              venue.distance = place["distance"] as! Int
              venue.location = CLLocationCoordinate2D(latitude: place["lat"]! as! Double, longitude: place["lng"]! as! Double)
              venues.append(venue)
            }
            let item = VenuesChatItem()
            item.venues = venues
            self.items.append(item)
            let indexPath = NSIndexPath(forRow: self.items.count - 1, inSection: 0)
            self.collectionView.insertItemsAtIndexPaths([indexPath])
          }
        })
      }
    } else if (a.action == "url") {
      let vc = SFSafariViewController(URL: NSURL(string: a.url!)!)
      vc.title = a.answer
      self.navigationController?.pushViewController(vc, animated: true)
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
        self.demoStep = 0
        self.currentStep = 0
        self.entryView.updateOptions([], alternativeEntry: nil)
        self.items.removeAll()
        self.collectionView.reloadData()
        self.history.removeAll()
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
  private func loadNextQuestion() {
    var lat = ""
    var lng = ""

    if (self.demoStep == 0) {
      lat = "51.153662"
      lng = "-0.182063"
    } else if (self.demoStep == 1) {
      lat = "51.5226651"
      lng = "-0.0878222"
    }

//    lat = "51.153662"
//    lng = "-0.182063"

    let historyData = try! NSJSONSerialization.dataWithJSONObject(self.history, options: NSJSONWritingOptions.PrettyPrinted)
    Alamofire.request(.POST, "http://dev.heidi.wx.rs/get_question", parameters: ["lat":lat, "lng":lng, "prev_answers":NSString(data: historyData, encoding: NSUTF8StringEncoding)!]).responseJSON { (response: Response<AnyObject, NSError>) in
      if (response.result.value == nil) {
        Alert(title: "Error", message: "Didn't get a valid response from the server.").showOkay()
        return
      }
      print(response.result.value!)
      let answers = response.result.value!["answers"] as! Array<Dictionary<String, AnyObject>>
      self.nextAnswers.removeAll()
      for a in answers {
        let newAnswer = Answer()
        newAnswer.id = a["id"] as! String
        if a["action"] as? NSNull != NSNull() {
          newAnswer.action = a["action"] as? String
        }
        newAnswer.answer = a["answer"] as! String
        if let loc = a["location"] {
          let d = loc as! Dictionary<String,AnyObject>
          newAnswer.location = CLLocationCoordinate2D(latitude: d["lat"]! as! Double, longitude: d["lng"]! as! Double)
        }
        if let url = a["url"] {
          newAnswer.url = url as? String
        }
        self.nextAnswers.append(newAnswer)
      }
      self.addMessage(response.result.value!["question"] as! String, showTyping: true)
      self.lastQuestion = response.result.value!["id"] as! String
    }
  }
}


// Venue selection
extension MainViewController: VenuePickerCellDelegate {
  func selectedVenue(venue: Venue) {
    self.nextAnswers = [Answer(answer: "🚗 Uber", "uber"), Answer(answer: "🗺 Navigate", "nav"), Answer(answer: "🚎 Bus", "bus")]
    for l in self.nextAnswers {
      l.location = venue.location
    }
    self.addMessage("How do you want to get there?", showTyping: true)
  }
}

