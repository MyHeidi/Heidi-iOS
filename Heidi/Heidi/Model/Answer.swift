//
//  Answer.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import CoreLocation

class Answer {

  var id: String!
  var action: String!
  private var _answer: String!
  var answer: String! {
    get {
      return _answer
    }
    set(newValue) {
      switch newValue {
      case "hotel_route":
        _answer = "🏨 Hotel"
      case "phone_charges":
        _answer = "📱 Data"
      case "country_info":
        _answer = "ℹ️ Info"
      default:
        assert(false, "unknown type: \(newValue)")
        _answer = ""
      }
    }
  }
  var location: CLLocationCoordinate2D?

  init() {

  }

  init(answer: String, _ action: String) {
    _answer = answer
    self.action = action
  }

}
