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

import Foundation
import CloudKit

class CloudKitCentral {
  
  var iCloudAccountIsAvailable = false
  let container: CKContainer
  let privateDB: CKDatabase
  let publicDB: CKDatabase
  var subscriptionsSaved = false
  var token: CKServerChangeToken?
  var tokenData: Data? {
    guard let token = token else { return nil }
    return NSKeyedArchiver.archivedData(withRootObject: token)
  }
  var createZoneOp: CKModifyRecordZonesOperation!
  var zoneCreated = false
  var qos: QualityOfService = .utility
  
  init() {
    self.container = CKContainer.default()
    self.privateDB = container.privateCloudDatabase
    self.publicDB = container.publicCloudDatabase
    print(">>>>>>>> CloudKitCentral zoneCreated \(self.zoneCreated)")
  }
  
  // MARK: - class singleton
  static let sharedCKCInstance = CloudKitCentral()
  class func sharedInstance() -> CloudKitCentral {
    return sharedCKCInstance
  }
  
  // Stopped working in beta 6: doesn't print, doesn't alert
  // Watch app doesn't use CloudKit
  func checkiCloudAccountStatus() {
    container.accountStatus() { accountStatus, error in
      if let error = error {
        print(">>> accountStatus ERROR: \(error.localizedDescription)")
      } else {
        switch accountStatus {
        case .available:
          print(">>> Account is available")
          self.iCloudAccountIsAvailable = true
          // in case this happens after deviceModel's didSet
          if !self.zoneCreated { self.createZone() }
        case .noAccount:
          print(">>> No Account")
          if let alertUserToSignIn = self.alertUserToSignIn { alertUserToSignIn() }
        case .couldNotDetermine:
          print(">>> Could not determine account")
        case .restricted:
          print(">>> Restricted account")
        }
      }
    }
  }
  
  // MARK: - Flo- and device-specific properties
  // View/Interface controller must set these four properties
  var alertUserToSignIn: (() -> Void)?
  var updateLocalData: ((CKRecord) -> Void)?
  var cacheLocalData: ((_ object: AnyObject, _ key: String) -> Void)?
  var deviceModel: String? {
    didSet {
      // accountStatus might be lagging, so also call createZone in its handler
      if !zoneCreated && iCloudAccountIsAvailable { createZone() }
    }
  }
  var deviceZone: CKRecordZone {
    guard let deviceModel = deviceModel else {
      return CKRecordZone(zoneName: "Unknown Device Zone")
    }
    return CKRecordZone(zoneName: "\(deviceModel) Zone")
  }
  let recordType = "DrinkEvent"
  
  // Only InterfaceController defines this, to test Watch CloudKit without iPhone
  var displayPublicRecord: ((CKRecord) -> Void)?
  
}

// Flo-specific methods and computed properties
extension CloudKitCentral {
  
  // This method runs after View/Interface controller sets deviceModel property
  // The modify record zones op succeeds even if zone already exists,
  // so no need to cache creation flags
  func createZone() {
    createZoneOp = CKModifyRecordZonesOperation(recordZonesToSave: [deviceZone], recordZoneIDsToDelete: nil)
    createZoneOp.modifyRecordZonesCompletionBlock = { _, _, error in
      if let error = error {
        print(">>>>>>>>>> createZonesOp ERROR: \(error.localizedDescription)")
      } else {
        self.zoneCreated = true
        print(">>>>>>>>>> createZonesOp success")
      }
    }
    privateDB.add(createZoneOp)
  }
  
  // Save DrinkEvent record; subscribe to changes after saving first record, which creates record type
  func saveDate(_ date: Date, viaWC: Bool) {
    print(">>>>>>>>>> saveDate: subsSaved flag \(subscriptionsSaved)")
    let record = CKRecord(recordType: recordType, zoneID: deviceZone.zoneID)
    record["date"] = date as NSDate
    privateDB.save(record) { _, error in
      if let error = error {
        print(">>>>>>>>>> saveDate to \(self.deviceZone.zoneID) ERROR \(error.localizedDescription)")
      } else {
        print(">>>>>>>>>> saveDate to \(self.deviceZone.zoneID) success")
        if viaWC, let update = self.updateLocalData {
          update(record)
        }
        #if os(ios)
        if !self.subscriptionsSaved {
          self.subscribeToChanges()
        }
        #endif
      }
    }
  }
  
  // watchOS 3 doesn't support CKSubscriptions
  // Subscription op fails if record type doesn't exist
    #if os(iOS)
  func subscribeToChanges() {
    let notificationInfo = CKNotificationInfo()
    notificationInfo.shouldSendContentAvailable = true // silent notification
    
    let newDrinkEventSubscription = CKDatabaseSubscription(subscriptionID: "newDrinkEvent")
    newDrinkEventSubscription.recordType = "DrinkEvent"
    newDrinkEventSubscription.notificationInfo = notificationInfo
    
    let subscribeOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [newDrinkEventSubscription], subscriptionIDsToDelete: [])
    
    subscribeOperation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
      if let error = error {
        print(">>>>>>>>>> subscribeOperation ERROR \(error.localizedDescription)")
      } else {
        print(">>>>>>>>>> subscribeOperation success \(subscriptions)")
        self.subscriptionsSaved = true
        if let cacheSuccess = self.cacheLocalData {
          cacheSuccess(true as AnyObject, LocalCache.subscriptionsSaved.rawValue)
        }
      }
    }
    privateDB.add(subscribeOperation)
  }
    #endif
  // Method called by application(_:didReceiveRemoteNotification:fetchCompletionHandler)
  // where fetchCompletionHandler is (UIBackgroundFetchResult) -> Void
  // callback argument is fetchCompletionHandler with argument UIBackgroundFetchResult.newData
  // Also called by View/InterfaceController at startup, with locally-cached token, qos .userInitiated
  func fetchDatabaseChanges(_ callback: @escaping () -> Void) {
    let changesOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
    changesOperation.fetchAllChanges = true
    
    // qos is .userInitiated to pull changes, .utility for push updates
    changesOperation.qualityOfService = qos
    
    // Block to handle zones with changed records
    changesOperation.recordZoneWithIDChangedBlock = { zoneID in
      let queryOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: nil)
      
      queryOperation.fetchAllChanges = true
      queryOperation.recordChangedBlock = { record in
        if let update = self.updateLocalData {
          update(record)
        }
      }
      self.privateDB.add(queryOperation)
        #if os(iOS)
        if !self.subscriptionsSaved {
          self.subscribeToChanges()
        }
        #endif
    }
    
    // Block to save intermediate change tokens
    changesOperation.changeTokenUpdatedBlock = { newToken in
      self.token = newToken
    }
    
    // Block to handle operation completion
    changesOperation.fetchDatabaseChangesCompletionBlock = {
      (newToken: CKServerChangeToken?, more: Bool, error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        // Cache final token
        self.token = newToken
        if let cacheLocalData = self.cacheLocalData, let tokenData = self.tokenData {
          cacheLocalData(tokenData as AnyObject, "changeToken")
        }
        
        // push: fetchCompletionHandler with argument UIBackgroundFetchResult.newData
        // pull: status message or empty handler
        callback()
      }
    }
    
    privateDB.add(changesOperation)
  }
  
  // method to test Watch CloudKit without iPhone
  func fetchPublicRecords() {
    let query = CKQuery(recordType: "DrinkEvent", predicate: NSPredicate(value: true))
    publicDB.perform(query, inZoneWith: nil) { results, error in
      if let error = error {
        print(">>>>>> fetchPublicRecords ERROR \(error.localizedDescription)")
      } else {
        if let displayPublicRecord = self.displayPublicRecord, let record = results?.first {
          print(">>>>>> fetchPublicRecords success \(results)")
          displayPublicRecord(record)
        }
      }
    }
  }
  
}
