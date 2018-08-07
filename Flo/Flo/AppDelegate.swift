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

import UIKit
import CloudKit
import WatchConnectivity

let NotificationDrinkDateOnWatch = "DrinkDateOnWatch"
let NotificationiPhoneDataUpdated = "iPhoneDataUpdated"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
  }()
  
  let ckCentral = CloudKitCentral.sharedInstance()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    application.registerForRemoteNotifications()
    
    // This doesn't work, at least not in the simulator
    NotificationCenter.default.addObserver(forName: Notification.Name.CKAccountChanged, object: nil, queue: OperationQueue.main) { notification in
      self.ckCentral.checkiCloudAccountStatus()
      print(">>> iCloud user status changed\n\(notification)")
    }
    
    setupWatchConnectivity()
    setupNotificationCenter()
    
    return true
  }
  
  // MARK: - Notification Center for WC
  private func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationiPhoneDataUpdated), object: nil, queue: nil) { (notification:Notification) -> Void in
      print(">>> setupNotificationCenter")
      self.sendFloDataToWatch(notification)
    }
  }
  
  // NOTE: remote notifications are not supported in the simulator
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print(">>> didRegisterForRemoteNotificationsWithDeviceToken \(deviceToken)")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(">>> didFailToRegisterForRemoteNotificationsWithError ERROR: \(error.localizedDescription)")
  }
  
  // Broken by beta 6; bug report 27862118 filed on Aug 17 2016
  // Fixed in GM
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//    let dict = userInfo //as! [String: Any]
////    let notification = CKNotification(fromRemoteNotificationDictionary: dict as! [AnyHashable(String) : NSObject])
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
    if notification.subscriptionID == "newDrinkEvent" {
      ckCentral.qos = .utility
      ckCentral.fetchDatabaseChanges {
        completionHandler(UIBackgroundFetchResult.newData)
      }
    }
  }

}

// MARK: Watch Connectivity
extension AppDelegate: WCSessionDelegate {
  
  func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.default()
      session.delegate = self
      session.activate()
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let watchDate = applicationContext["watchDate"] as? Date {
      print(">>> didReceiveApplicationContext from Watch: \(watchDate)")
      ckCentral.saveDate(watchDate, viaWC: true)
//      DispatchQueue.main.async(execute: {
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationDrinkDateOnWatch), object: nil)
//      })
    }
  }
  
  func sendFloDataToWatch(_ notification: Notification) {
    guard WCSession.isSupported() && WCSession.default().isWatchAppInstalled else { return }
    
    let floData = FloData.sharedInstance()
    let currentDrinkTotal = floData.drinkTotal
    print(">>> sendFloDataToWatch drinkTotal \(floData.drinkTotal)")
    do {
      let dictionary = [LocalCache.startDate.rawValue: floData.startDate, LocalCache.drinkTotal.rawValue: currentDrinkTotal] as [String : Any]
      try WCSession.default().updateApplicationContext(dictionary as [String : AnyObject])
    } catch {
      print(">>> sendFloDataToWatch ERROR: \(error.localizedDescription)")
    }
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    print(">>> WC Session did become inactive")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print(">>> WC Session did deactivate")
    WCSession.default().activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith
    activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print(">>> WC Session activation failed with error: " +
        "\(error.localizedDescription)")
      return
    }
    print(">>> WC Session activated with state: " +
      "\(activationState.rawValue)")
  }
  
}

