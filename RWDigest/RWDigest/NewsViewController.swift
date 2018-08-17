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

class NewsViewController: UITableViewController {
  
  let news: News? = ContentProvider.sharedProvider.news
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "RW Digest"
    tableView.contentInset = UIEdgeInsets(top: -36.0, left: 0, bottom: 0, right: 0)
  }
  
  override func restoreUserActivityState(_ activity: NSUserActivity) {
    super.restoreUserActivityState(activity)
    _ = navigationController?.popToViewController(self, animated: true)
    guard let userInfo = activity.userInfo else { return }
    let handoff = Handoff()
    switch activity.activityType {
    case Handoff.ActivityType.readStory.rawValue:
      guard let storyID = userInfo[handoff.activityValueKey] as? String else {
        presentStoryNotFoundAlertController()
        return
      }
      guard let story = news?.storyWithIdentifier(storyID) else {
        presentStoryNotFoundAlertController()
        return
      }
      let controller = presentStoryViewControllerWithStory(story, animated: true)
      controller.restoreUserActivityState(activity)
    case Handoff.ActivityType.viewNews.rawValue:
      fallthrough
    default:
      break
    }
  }
  
  // MARK: UITableView data source and delegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count = news?.stories.count else { return 0 }
    return count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath)
    if let story = news?.stories[(indexPath as NSIndexPath).row] {
      cell.textLabel?.text = story.title
      cell.detailTextLabel?.text = story.formattedDate
      let imageName = (story.isRead ? "bullet-viewed" : "bullet-not_viewed")
      cell.imageView?.image = UIImage(named: imageName)
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let story = news?.stories[(indexPath as NSIndexPath).row] else { return }
    story.isRead = true
    tableView.reloadRows(at: [indexPath], with: .automatic)
    presentStoryViewControllerWithStory(story, animated: true)
  }
  
  // MARK: Helper
  
  /// A convenient helper method to present StoryViewController. Conveniently,
  /// it returns a pointer to the controller that's being presented so you can
  /// do further customizations if needed.
  @discardableResult func presentStoryViewControllerWithStory(_ story: Story, animated: Bool) -> StoryViewController {
    let controller = storyboard?.instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
    controller.story = story
    navigationController?.pushViewController(controller, animated: animated)
    return controller
  }
  
  /// A convenient helper method to present a UIAlertViewController with a 
  /// generic statement that a story was not found.
  func presentStoryNotFoundAlertController() {
    let controller = AlertHelper.dismissOnlyAlertController(withTitle: "Error", message: "Story not found.")
    present(controller, animated: true, completion: nil)
  }
  
}
