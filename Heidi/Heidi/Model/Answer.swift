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
  var action: String?
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
      case "leisure_restaurants":
        _answer = "🍽 Restaurant"
      case "leisure_bars":
        _answer = "🍺 Bar"
      case "leisure_clubs":
        _answer = "🎉 Club"
      case "airport_roaming_yes":
        _answer = "✅ Yes"
      case "airport_roaming_no":
        _answer = "❌ No"
      case "leisure_restaurants_cuisine_italian":
        _answer = "🍝 Italian"
      case "leisure_restaurants_cuisine_indian":
        _answer = "🍛 Indian"
      case "leisure_restaurants_cuisine_fastfood":
        _answer = "🍟 Fast Food"
      case "leisure_restaurants_distance_5":
        _answer = "🕐 5 min"
      case "leisure_restaurants_distance_10":
        _answer = "🕑 10 min"
      case "leisure_restaurants_distance_30":
        _answer = "🕧 30 min"
      case "photo_share_photo_yes":
        _answer = "👍 Share photo"
      case "photo_share_photo_no":
        _answer = "🙈 Don‘t share"
      default:
        assert(false, "unknown type: \(newValue)")
        _answer = ""
      }
    }
  }
  var location: CLLocationCoordinate2D?
  var url: String?

  init() {

  }

  init(answer: String, _ action: String) {
    _answer = answer
    self.action = action
  }

}
