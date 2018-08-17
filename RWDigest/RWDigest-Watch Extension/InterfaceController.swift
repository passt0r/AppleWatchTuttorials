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

import WatchKit

class InterfaceController: WKInterfaceController {
  
  /// List of stories, the data source of the interface controller.
  private let stories: [Story] = {
    let stories = ContentProvider.sharedProvider.news?.stories ?? []
    return stories
  }()
  
  /// The interface table.
  @IBOutlet var interfaceTable: WKInterfaceTable?
  
  // MARK: Interface Life Cycle
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    setTitle("RWDigest")
    
    // Initialize table.
    interfaceTable?.setNumberOfRows(stories.count, withRowType: "TextLabelRowIdentifier")
  }
  
  override func willActivate() {
    super.willActivate()
    
    // Update table.
    for (index, story) in stories.enumerated() {
      let controller = interfaceTable?.rowController(at: index) as! TextLabelRowController
      controller.textLabel?.setText(story.title)
    }
    
     let handoff = Handoff()
    let userInfo: [AnyHashable: Any] = [
      handoff.version.key: handoff.version.number,
      handoff.activityValueKey: ""
    ]
    updateUserActivity(Handoff.ActivityType.viewNews.rawValue, userInfo: userInfo, webpageURL: nil)
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    guard segueIdentifier == "StoryInterfaceSegue" && table == interfaceTable else { return nil }
    let story = stories[rowIndex]
    return story
  }
}
