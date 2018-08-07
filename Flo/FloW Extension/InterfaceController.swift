/*
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
import CloudKit

class InterfaceController: WKInterfaceController {
  @IBOutlet var drinkAverageLabel: WKInterfaceLabel!
  @IBOutlet var infoLabel: WKInterfaceLabel!
  @IBOutlet var button: WKInterfaceButton!
  @IBOutlet var drinkCountLabel: WKInterfaceLabel!
  
  // Complications not working?
//  var shortTextForComplication: String {
//    return String(format: "%.1f 🚰", floData.drinkAverage)
//  }
//  var longTextForComplication: String {
//    return String(format: "%.1f 🚰 since \(floCal.formattedShort(floData.startDate))", floData.drinkAverage)
//  }
  
  let floData = FloData.sharedInstance()
  let floCal = FloCalendar()
    let ckCentral = CloudKitCentral.sharedInstance()
  
  @IBAction func buttonTapped() {
    floData.drinkTotal += 1
    floData.lastDate = Date()
    saveData()
    updateInterface()
  }
  
  // Save new drink event to iCloud database directly, or via iPhone
  func saveData() {
      // send to iPhone via Watch Connectivity
    if ckCentral.iCloudAccountIsAvailable {
        ckCentral.saveDate(floData.lastDate, viaWC: false)
    } else {
        // send to iPhone via Watch Connectivity
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue:
                NotificationDrinkDateOnWatch), object: nil)
    }    
    // Update UserDefaults
    UserDefaults.standard.set(floData.drinkTotal, forKey: LocalCache.drinkTotal.rawValue)
  }
  
  func updateInterface() {
    drinkAverageLabel.setText(String(format: "%.1f", floData.drinkAverage))
    drinkCountLabel.setText(String(floData.drinkTotal))
    infoLabel.setText("Since \(floCal.formattedShort(floData.startDate))")
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    ckCentral.checkiCloudAccountStatus()
    ckCentral.deviceModel = WKInterfaceDevice.current().model
    ckCentral.updateLocalData = { record in
        self.floData.drinkTotal += 1
        print(">> updateLocalData with \(record["date"] as! Date)")
    }
    ckCentral.cacheLocalData = { object, key in
        UserDefaults.standard.set(object, forKey: key)
    }
    ckCentral.alertUserToSignIn = {
        let okAction = WKAlertAction(title: "OK", style: .default, handler: {
        })
        self.presentAlert(withTitle: "Not Signed In", message: "Please sign into iCloud on your paired iPhone", preferredStyle: .alert, actions: [okAction])
    }
    // Uncomment this line to test the Watch app without its iPhone
        ckCentral.fetchPublicRecords()
    
    // CloudKitCentral housekeeping
    
    // recordChangedBlock calls this to handle new record (pull change)
    
    // ckCentral calls this to cache change token
    
    // checkiCloudAccountStatus() calls this to display sign-in alert
    
    // fetchPublicRecords() calls this to display the record in the hidden label
//    ckCentral.displayPublicRecord = { record in
//      self.hiddenLabel.setHidden(false)
//      self.hiddenLabel.setText(self.floCal.formattedShort(record["date"] as! Date))
//    }
    
    // watchOS-specific: reload UserDefaults data
    if UserDefaults.standard.integer(forKey: LocalCache.drinkTotal.rawValue) > 0 {
      floData.drinkTotal = UserDefaults.standard.integer(forKey: LocalCache.drinkTotal.rawValue)
      floData.startDate = UserDefaults.standard.object(forKey: LocalCache.startDate.rawValue) as! Date
    } else {
      // No UserDefaults, so save startup values in UserDefaults
      UserDefaults.standard.set(floData.startDate, forKey: LocalCache.startDate.rawValue)
      UserDefaults.standard.set(floData.drinkTotal, forKey: LocalCache.drinkTotal.rawValue)
    }
    
    updateInterface()
  }
  
}
