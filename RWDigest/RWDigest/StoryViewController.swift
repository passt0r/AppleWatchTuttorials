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
import SafariServices

typealias StoryCellAction = (() -> Void)
typealias StoryCells = [StoryCell]

/// A model that describes a Story cell model.
struct StoryCell {
  
  /// Cell identifier.
  let identifier: String
  
  /// Expected index of the cell.
  let index: Int
  
  /// Content of the cell.
  let content: String
  
  /// An action block associated with the receiver.
  let action: StoryCellAction?
  
  init(index: Int, identifier: String, content: String, action: StoryCellAction?) {
    self.index = index
    self.identifier = identifier
    self.content = content
    self.action = action
  }
}

/// A UI (view) model that describes the structure of a Story UI.
struct StoryUI {
  
  let storyCells: StoryCells
  let numberOfCells: Int
  
  init(cells: StoryCells) {
    self.storyCells = cells
    self.numberOfCells = cells.count
  }
  
  /// A convenient method to return the cell identifier at a given index.
  func cellIdentifierAtIndex(_ index: Int) -> String {
    let matches = storyCells.filter() { return $0.index == index }
    let match = matches.first!
    return match.identifier
  }
  
  /// A convenient method to return content of a cell at a given index.
  func contentForCellAtIndex(_ index: Int) -> String {
    let matches = storyCells.filter() { return $0.index == index }
    let match = matches.first!
    return match.content
  }
  
  /// A convenient method to return the associated action for a cell at a 
  /// given index, if any.
  func actionForCellAtIndex(_ index: Int) -> StoryCellAction? {
    let matches = storyCells.filter() { return $0.index == index }
    let match = matches.first!
    return match.action
  }
  
}

class StoryViewController: UITableViewController {
  
  /// The story (data model) of the receiver. Setting story (data model) 
  /// automatically sets the view model for the receiver.
  var story: Story? {
    didSet {
      guard let story = story else { return }
      
      // Now that story is set to a valid (non-nil) story, create a view model for that.
      unowned let weakSelf = self
      let titleCell = StoryCell(index: 0, identifier: "TitleCellIdentifier", content: story.title, action :nil)
      let briefCell = StoryCell(index: 1, identifier: "BriefCellIdentifier", content: story.brief, action: nil)
      let linkCell  = StoryCell(index: 2, identifier: "LinkCellIdentifier", content: story.link.absoluteString, action: {
        
        let controller = SFSafariViewController(url: story.link, entersReaderIfAvailable: true)

        weakSelf.navigationController?.pushViewController(controller, animated: true)
      })
      self.viewModel = StoryUI(cells: [titleCell, briefCell, linkCell])
    }
  }
  
  /// A view model for the receiver based on the Story property.
  /// This is set automatically when 'story' property is set.
  var viewModel: StoryUI?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: -36.0, left: 0, bottom: 0, right: 0)
  }
  
  override func restoreUserActivityState(_ activity: NSUserActivity) {
    super.restoreUserActivityState(activity)
    guard let story = story else { return }
    let controller = SFSafariViewController(url: story.link, entersReaderIfAvailable: true)
    navigationController?.pushViewController(controller, animated: true)
  }
  
  // MARK: UITableView data source and delegate
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count = viewModel?.numberOfCells else { return 0 }
    return count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // If viewModel is nil, 0 should have been returned in tableView(_:numberOfRowsInSection:). 
    // It's a programmer error; code should have never reached this point with nil view model.
    guard let viewModel = viewModel else { return UITableViewCell() }
    
    let index = (indexPath as NSIndexPath).row
    let identifier = viewModel.cellIdentifierAtIndex(index)
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    let content = viewModel.contentForCellAtIndex(index)
    cell.textLabel?.text = content
    return cell
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    // If viewModel is nil, 0 should have been returned in tableView(_:numberOfRowsInSection:).
    // It's a programmer error; code should have never reached this point with nil view model.
    guard let viewModel = viewModel else { return 0.0 }
    
    let index = (indexPath as NSIndexPath).row
    let content = viewModel.contentForCellAtIndex(index)
    let estimatedHeight = StringHelper.estimatedHeightForString(content, boundedToWidth: tableView.bounds.width)
    return estimatedHeight
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let action = viewModel?.actionForCellAtIndex((indexPath as NSIndexPath).row) else { return }
    action()
  }
  
}
