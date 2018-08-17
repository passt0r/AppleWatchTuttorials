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

import Foundation

class Binder {
  
  /// A date formatter to convert yyyy-MM-dd date strings from content plist file into NSDate objects.
  let stringToDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  /// A date formatter to convert a NSDate object to a localized user-friendly date string to display in UI.
  let dateToStringFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = DateFormatter.Style.long
    return formatter
    }()
  
  /// Reads and parses the newsletter content plist file, binds it and returns a News object.
  func readContent() -> News? {
    
    guard let URL = Bundle(for: Binder.self).url(forResource: "Content", withExtension: "plist") else { return nil }
    
    var stories = [Story]()
    let content = NSDictionary(contentsOf: URL)
    content?.enumerateKeysAndObjects({ (key: Any, value: Any, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      
      if let storyTitle = key as? String, let storyProperties = value as? NSDictionary {
        
        let identifier = storyProperties["StoryID"] as! String
        let brief = storyProperties["Brief"] as! String
        let linkString = storyProperties["Link"] as! String
        let link = Foundation.URL(string: linkString)!
        let dateString = storyProperties["Date"] as! String
        let date = self.stringToDateFormatter.date(from: dateString)!
        let formattedDate = self.dateToStringFormatter.string(from: date)
        let story = Story(title: storyTitle, brief: brief, link: link, identifier: identifier, date: date, formattedDate: formattedDate)
        stories.append(story)
      }
    })
    
    // Sort stories based on publication date, with most recent ones on top.
    stories = stories.sorted() {
      let dateComparisonResult = $0.date.compare($1.date as Date)
      // If both stories have the same date, sort alphabetically.
      if dateComparisonResult == ComparisonResult.orderedSame {
        return $0.title.compare($1.title) == ComparisonResult.orderedAscending
      }
      return dateComparisonResult == ComparisonResult.orderedDescending
    }
    
    let news = News(stories: stories)
    return news
  }
  
}
