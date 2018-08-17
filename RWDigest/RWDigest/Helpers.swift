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

/// A helper class for String.
class StringHelper {
  
  /// A helper method to return a CGFloat, estimated height of a given string 
  /// bounded to a width. Font size and line breaking mode are assumed.
  class func estimatedHeightForString(_ string: String, boundedToWidth width: CGFloat) -> CGFloat {
    let hypotheticalSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    let options = NSStringDrawingOptions.usesLineFragmentOrigin
    let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
    let estimatedRect = string.boundingRect(with: hypotheticalSize, options: options, attributes: attributes, context: nil)
    return estimatedRect.height
  }
  
}

/// A helper class for UIAlertController.
class AlertHelper {
  
  /// A helper method to return a UIAlertController instance that has only 
  /// one action button, i.e. Dismiss with a given message.
  class func dismissOnlyAlertController(withTitle title: String, message: String) -> UIAlertController {
    let controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    controller.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
    return controller
  }
}
