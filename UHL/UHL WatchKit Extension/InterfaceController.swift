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
import Foundation


class InterfaceController: WKInterfaceController {
  
  @IBOutlet var teamLogo: WKInterfaceImage!
  @IBOutlet var teamNameLabel: WKInterfaceLabel!
  @IBOutlet var nextMatchLabel: WKInterfaceLabel!
  @IBOutlet var recordLabel: WKInterfaceLabel!
  @IBOutlet var scheduleButton: WKInterfaceButton!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
  }
  
  override func willActivate() {
    super.willActivate()
    
    teamNameLabel.setText(ourTeam.name)
    teamLogo.setImageNamed(ourTeam.logoName)
    
    if let nextMatch = season.upcomingMatches.first {
      nextMatchLabel.setText("\(nextMatch.date.simpleDate) @ \(nextMatch.date.simpleTime)")
    } else {
      scheduleButton.setHidden(true)
    }
    
    recordLabel.setText("\(season.record)")
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
    
  }
  

}
