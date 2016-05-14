//
//  SizeDelegate.swift
//  Heidi
//
//  Created by Dylan Marriott on 14/05/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol SizeDelegate: class {
  func subviewDidChangeSize(view: UIView)
}
