/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

extension Date {
  var simpleDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: self)
  }
  var simpleTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "a"
    var amPm = formatter.string(from: self)
    amPm = String(amPm.characters.first!).lowercased()
    formatter.dateFormat = "h:mm"
    let time = formatter.string(from: self)
    return "\(time)\(amPm)"
  }
  var mediumDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Dec 25, 2014
    return formatter.string(from: self)
  }
  var yesterday: Date {
    return self.addingTimeInterval(-24 * 60 * 60)
  }
  var tomorrow: Date {
    return self.addingTimeInterval(24 * 60 * 60)
  }
}
