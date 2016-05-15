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
import Photos

class ChatItem: NSObject {
  var writing = false
  var ownItem = false
}

class StringChatItem: ChatItem {
  var value = ""
}

class PhotoChatItem: ChatItem {
  var image: UIImage!
}

class VenuesChatItem: ChatItem {
  var venues = [Venue]()
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SizeDelegate, EntryViewDelegate {

  let entryHeight = CGFloat(64)
  private var collectionView: UICollectionView!
  private var entryView: EntryView!
  private var sizingCell: ChatCell!
  private var photoSizingCell: PhotoChatCell!
  private var items = [ChatItem]()
  private var currentTypingItem: StringChatItem?
  private var currentStep = 0
  private var nextAnswers = [Answer]()
  private var finished = true
  private var history = [[String:String]]()
  private var lastQuestion = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Heidi"

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 20

    self.collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - entryHeight), collectionViewLayout: layout)
    self.collectionView!.registerClass(ChatCell.self, forCellWithReuseIdentifier: "chatCell")
    self.collectionView!.registerClass(VenuePickerCell.self, forCellWithReuseIdentifier: "venuePickerCell")
    self.collectionView!.registerClass(PhotoChatCell.self, forCellWithReuseIdentifier: "photoChatCell")
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 10, 0)
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 10, 0)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.alwaysBounceVertical = true
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.collectionView)

    self.sizingCell = ChatCell(frame: CGRectMake(0, 0, self.view.frame.width, 0))
    self.photoSizingCell = PhotoChatCell(frame: CGRectMake(0, 0, self.view.frame.width, 0))

    self.entryView = EntryView(frame: CGRect(x: 0, y: self.view.frame.height - entryHeight, width: self.view.frame.width, height: entryHeight))
    self.entryView.delegate = self
    self.view.addSubview(self.entryView)


    NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
      if (self.finished) {
        self.currentStep = 0
        self.entryView.updateOptions([], alternativeEntry: nil)
        self.items.removeAll()
        self.collectionView.reloadData()
        self.history.removeAll()

        self.delay(0.2) {
          //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "simPhoto")
          self.loadNextQuestion()
        }
      }
      self.finished = true
    }

    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
      self.keyboardWillShowOrHide(notification)
    }
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
      self.keyboardWillShowOrHide(notification)
    }


    self.delay(0.1) {
      self.loadNextQuestion()
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
    } else if (item is PhotoChatItem) {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoChatCell", forIndexPath: indexPath) as! PhotoChatCell
      cell.item = item as! PhotoChatItem
      cell.sizeDelegate = self
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
    } else if (item is PhotoChatItem) {
      self.photoSizingCell.item = item as! PhotoChatItem
      return self.photoSizingCell.sizeThatFits(CGSizeMake(self.view.frame.width, 0))
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
    self.addMessage(text, showTyping: false, ownItem: true) { 
      self.sendCustomQuestion(text)
    }
  }

  func entryViewSelectedAnswer(index: Int, value: String) {
    self.finished = false
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
        var parms = ["lat":"51.5225996", "lng":"-0.085515", "prev_answers":NSString(data: historyData, encoding: NSUTF8StringEncoding)!]
        if (a.url! == "/action/twitter") {
          parms["status"] = "Having a good time at AngelHack London! #AH9 #AngelHackLondon"
          parms["photo"] = "test.png"
        }
        Alamofire.request(.POST, "http://dev.heidi.wx.rs"+a.url!, parameters: parms).responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
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
    } else if (a.action == nil) {
      self.addMessage(value, showTyping: false, ownItem: true) {
        self.showEndMessage()
      }
    }
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

    let ud = NSUserDefaults.standardUserDefaults()
    if (ud.boolForKey("simPhoto")) {
      ud.setBool(false, forKey: "simPhoto")
      lat = "51.5226651"
      lng = "-0.0878222"
      self.uploadPhoto(lat, lng)
    } else if (ud.boolForKey("simAirport")) {
      ud.setBool(false, forKey: "simAirport")
      lat = "51.153662"
      lng = "-0.182063"
      self.loadQuestion(lat, lng)
    } else {
      lat = "51.5226651"
      lng = "-0.0878222"
      self.loadQuestion(lat, lng)
    }
  }

  private func loadQuestion(lat: String, _ lng: String) {
    let historyData = try! NSJSONSerialization.dataWithJSONObject(self.history, options: NSJSONWritingOptions.PrettyPrinted)
    Alamofire.request(.POST, "http://dev.heidi.wx.rs/get_question", parameters: ["lat":lat, "lng":lng, "prev_answers":NSString(data: historyData, encoding: NSUTF8StringEncoding)!]).responseJSON { (response: Response<AnyObject, NSError>) in
      if (response.result.value == nil) {
        Alert(title: "Error", message: "Didn't get a valid response from the server.").showOkay()
        return
      }
      self.parseResult(response.result.value! as! [String : AnyObject])
    }
  }

  private func uploadPhoto(lat: String, _ lng: String) {

    let userInfo = ["lat":lat, "lng":lng]
    var photo: UIImage?

    let imgManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true
    let fetchOptions = PHFetchOptions()
    fetchOptions.fetchLimit = 1
    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]

    if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
      if fetchResult.count > 0 {
        // Perform the image request
        imgManager.requestImageForAsset(fetchResult.objectAtIndex(0) as! PHAsset, targetSize: CGSize(width: 320, height: 320), contentMode: PHImageContentMode.AspectFit, options: requestOptions, resultHandler: { (image, _) in
          photo = image
        })
      }
    }

    if let _image = photo {
      let item = PhotoChatItem()
      item.image = _image
      item.ownItem = true
      self.items.append(item)
      let indexPath = NSIndexPath(forRow: self.items.count - 1, inSection: 0)
      self.collectionView.insertItemsAtIndexPaths([indexPath])
    }

    Alamofire.upload(.POST, "http://dev.heidi.wx.rs/upload/photo", multipartFormData: {
      multipartFormData in
      if let _image = photo {
        if let imageData = UIImagePNGRepresentation(_image) {
          multipartFormData.appendBodyPart(data: imageData, name: "photo", fileName: NSUUID().UUIDString + ".png", mimeType: "image/png")
        }
      }
      for (key, value) in userInfo {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      }, encodingCompletion: { encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.responseJSON { response in
            self.parseResult(response.result.value! as! [String:AnyObject])
          }
        case .Failure(let encodingError):
          print(encodingError)
        }
      }
    )
  }

  private func parseResult(value:[String:AnyObject]) {
    let answers = value["answers"] as! Array<Dictionary<String, AnyObject>>
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
    self.addMessage(value["question"] as! String, showTyping: true)
    self.lastQuestion = value["id"] as! String
  }

  private func sendCustomQuestion(q: String) {
    let lat = "51.5226651"
    let lng = "-0.0878222"

    Alamofire.request(.POST, "http://dev.heidi.wx.rs/ask_question", parameters: ["lat":lat, "lng":lng, "question":q]).responseJSON { (response: Response<AnyObject, NSError>) in
      if (response.result.value == nil) {
        Alert(title: "Error", message: "Didn't get a valid response from the server.").showOkay()
        return
      }
      if let answer = response.result.value!["answer"] as? String {
        self.addMessage(answer, showTyping: true)
      }
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


// Keyboard handling
extension MainViewController {
  func keyboardWillShowOrHide(notification: NSNotification) {
    let userInfo = notification.userInfo!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
    var keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
    keyboardFrameEnd = self.view.convertRect(keyboardFrameEnd, toView: nil)
    let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
    UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
      self.entryView.frame.origin.y = keyboardFrameEnd.origin.y - self.entryHeight
      self.collectionView.frame.size.height = keyboardFrameEnd.origin.y - self.entryHeight
    }) { (finished: Bool) in

    }
  }
}
