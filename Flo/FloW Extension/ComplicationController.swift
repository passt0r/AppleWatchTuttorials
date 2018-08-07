//
//  $(PRODUCT_MODULE_NAME).swift
//  Flo
//
//  Created by Audrey M Tam on 9/08/2016.
//  Copyright © 2016 Caroline Begbie. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
  
  let floData = FloData.sharedInstance()
  var averageText: String {
    return String(format: "%.1f 🚰", floData.drinkAverage)
  }
  var dateText: String {
    return DateFormatter.localizedString(from: floData.startDate, dateStyle: .short, timeStyle: .short)
  }
  
  // MARK: Register
  func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
    //handler(nil)

    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: averageText)
      handler(smallFlat)
    } else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(
        text: averageText + dateText, shortText: averageText)
      handler(largeFlat)
    }
  }
  
  // MARK: Provide Data
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    handler(nil)
  }
  
  // MARK: Time Travel
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    handler([])
  }
}
