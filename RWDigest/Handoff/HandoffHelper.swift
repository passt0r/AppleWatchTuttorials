//
//  HandoffHelper.swift
//  RWDigest
//
//  Created by Dmytro Pasinchuk on 8/17/18.
//  Copyright © 2018 www.razeware.com. All rights reserved.
//

import Foundation

struct Version {
  let key: String
  let number: Int
}

struct Handoff {
  
  enum ActivityType: String {
    case viewNews   = "com.razeware.rwdigest.news"
    case readStory  = "com.razeware.rwdigest.story"
  }
  
  let activityValueKey = "activityValue"
  let version = Version(key: "version", number: 1)
}
