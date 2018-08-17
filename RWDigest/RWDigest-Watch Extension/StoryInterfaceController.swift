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

class StoryInterfaceController: WKInterfaceController {

  @IBOutlet var titleLabel: WKInterfaceLabel?
  @IBOutlet var briefLabel: WKInterfaceLabel?
  var story: Story?
  
  // MARK: Interface Life Cycle
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    guard let story = context as? Story else { return }
    self.story = story
  }
  
  override func willActivate() {
    super.willActivate()
    titleLabel?.setText(story?.title)
    briefLabel?.setText(story?.brief)
    let handoff = Handoff()
    guard let story = story else { return }
    let userInfo: [AnyHashable: Any] = [
      handoff.version.key: handoff.version.number,
      handoff.activityValueKey: story.identifier
    ]
    updateUserActivity(Handoff.ActivityType.readStory.rawValue, userInfo: userInfo, webpageURL: nil)
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
}
