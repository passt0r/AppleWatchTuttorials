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
import WatchConnectivity

let NotificationPurchasedMovieOnWatch = "PurchasedMovieOnWatch"

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  
  lazy var documentsDirectory: String = {
      return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }()
  
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
    }()
  
  func applicationDidFinishLaunching() {
    setupWatchConnectivity()
    setupNotificationCenter()
  }
  
  // MARK: - Notification Center
  
  private func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationPurchasedMovieOnWatch), object: nil, queue: nil) { (notification:Notification) -> Void in
      self.sendPurchasedMoviesToPhone(notification)
    }
  }
}

// MARK: - Watch Connectivity
extension ExtensionDelegate: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("WC Session activation failed with error: " + "\(error.localizedDescription)")
      return
    }
    print("WC Session activated with state: " + "\(activationState.rawValue)")
  }
  
  
  func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session  = WCSession.default()
      session.delegate = self
      session.activate()
    }
  }
  
  func sendPurchasedMoviesToPhone(_ notification:Notification) {
    if WCSession.isSupported() {
      if let movies = TicketOffice.sharedInstance.purchasedMovieTicketIDs() {
        let session = WCSession.default()
        do {
          let dictionary = ["movies": movies]
          try session.updateApplicationContext(dictionary)
        } catch {
          print("ERROR: \(error)")
        }
      }
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let movies = applicationContext["movies"] as? [String] {
      TicketOffice.sharedInstance.purchaseTicketsForMovies(movies)
      DispatchQueue.main.async {
        WKInterfaceController.reloadRootControllers(withNames: ["PurchasedMovieTickets"], contexts: nil)
      }
    }
  }
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    if let movieID = userInfo["movie_id"] as? String,
      let rating = userInfo["rating"] as? String {
      TicketOffice.sharedInstance.rateMovie(movieID,
                                            rating: rating)
    }
  }
  
}
