//
//  ComplicationController.swift
//  TideWatch WatchKit App Extension
//
//  Created by Dmytro Pasinchuk on 8/16/18.
//  Copyright © 2018 razeware. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
  // MARK: Register
  func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Swift.Void) {
    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: "+2.6m")
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "tide_high")!)
      handler(smallFlat)
    } else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: "Rising, +2.6m", shortText:"+2.6m")
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "tide_high")!)
      handler(largeFlat)
    }
  }
  // MARK: Provide Data
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    let conditions = TideConditions.loadConditions()
    guard let waterLevel = conditions.currentWaterLevel else {
      // No data is cached yet
      handler(nil)
      return
    }
    let tideImageName: String
    switch waterLevel.situation {
    case .High: tideImageName = "tide_high"
    case .Low: tideImageName = "tide_low"
    case .Rising: tideImageName = "tide_rising"
    case .Falling: tideImageName = "tide_falling"
    default: tideImageName = "tide_high"
    }
    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: waterLevel.shortTextForComplication)
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: tideImageName)!)
      handler(CLKComplicationTimelineEntry(date: waterLevel.date, complicationTemplate: smallFlat))
    } else {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(
        text: waterLevel.longTextForComplication,
        shortText:waterLevel.shortTextForComplication)
      largeFlat.imageProvider = CLKImageProvider(
        onePieceImage: UIImage(named: tideImageName)!)
      handler(CLKComplicationTimelineEntry(
        date: waterLevel.date, complicationTemplate: largeFlat))
    }
  }
  // MARK: Time Travel
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    handler([])
  }
  
}
