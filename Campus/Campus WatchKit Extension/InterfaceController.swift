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
import Foundation

enum InteractionMode: String {
    case move, zoom, inspect
    
    mutating func next() {
        switch self {
        case .move:
            self = .zoom
        case .zoom:
            self = .inspect
        case .inspect:
            self = .move }
    }
}

class InterfaceController: WKInterfaceController {
  
  @IBOutlet var graphImage: WKInterfaceImage!
    
    var interactionMode: InteractionMode! {
        didSet {
            switch interactionMode! {
            case .move, .zoom:
                self.setTitle("[\(interactionMode.rawValue.capitalized) mode]")
                highlightedPointIndex = nil
            case .inspect:
                highlightedPointIndex = preparedData().count / 2
            }
            generateImage()
        }
    }
    
    var accumulatedDigitalCrownDelta = 0.0
    
    var offset = 0.0
    
    var zoom = 1.0
    
    var highlightedPointIndex: Int? {
        didSet {
            if highlightedPointIndex != nil {
                self.setTitle(stringFromHighlightedIndex())
            }
        }
    }
    
    var previousPanPoint: CGPoint?
  
  override func awake(withContext context: Any?) {
    interactionMode = .move
    crownSequencer.delegate = self
  }
  
  override func willActivate() {
    super.willActivate()
    
    generateImage()
    crownSequencer.focus()
  }
    
    @IBAction func zoomMenuItemPressed() {
        interactionMode = .zoom
    }
    @IBAction func moveMenuItemPressed() {
        interactionMode = .move
    }
    @IBAction func inspectMenuItemPressed() {
        interactionMode = .inspect
    }
    @IBAction func resetMenuItemPressed() {
        reset()
    }
    
    @IBAction func tapGestureRecognized() {
        interactionMode.next()
    }
    
    @IBAction func panGestureRecognized(_ sender: Any) {
        // 1
        guard let panGesture = sender as? WKPanGestureRecognizer else {
            return
        }
        // 2
        switch panGesture.state {
        // 3
        case .began:
            previousPanPoint = panGesture.locationInObject()
        // 4
        case .changed:
            guard let previousPanPoint = previousPanPoint else {
                return
            }
            let currentPanPoint = panGesture.locationInObject()
            let deltaX = currentPanPoint.x - previousPanPoint.x
            // 5
            let percentageChange = deltaX / self.contentFrame.size.width
            handleInteraction(Double(percentageChange))
            self.previousPanPoint = currentPanPoint
        // 6
        default:
            previousPanPoint = nil
            break
        }
    }
    
    private func reset() {
        offset = 0
        zoom = 1
        generateImage()
    }
  
  // Preparing data
  
  func stringFromHighlightedIndex() -> String {
    let data = preparedData()
    let census = data[highlightedPointIndex!]
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    let dateString = dateFormatter.string(from: census.timestamp)
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let numberString = numberFormatter.string(from: NSNumber(value:
        census.attendance))!
    return "\(dateString): \(numberString)"
  }
  
  func preparedData() -> [Census] {
    
//    let dataCountOffset = Int(round(Double(measurementsPerDay) * offset))
//
//    let minRange = censuses.count - measurementsPerDay - dataCountOffset
//    let maxRange = censuses.count - dataCountOffset
//
//    var data = [Census]()
//    for x in minRange..<maxRange {
//        if x < censuses.count && x >= 0 {
//            data.append(censuses[x])
//        }
//    }
//    return data
    
    // 1
    let dataCount = Int(round(Double(measurementsPerDay) * zoom))
    let dataCountOffset = Int(round(Double(measurementsPerDay) *
        self.offset))
    // 2
    let minRange = censuses.count - dataCount - dataCountOffset
    let maxRange = censuses.count - dataCountOffset
    var data = [Census]()
    for x in minRange..<maxRange {
        if x < censuses.count && x >= 0 {
            data.append(censuses[x])
        }
    }
    return data
  }
  
  func preparedDemarcations() -> [GraphDemarcation] {
    let censusesAroundMidnight = preparedData().enumerated().filter() {
      index, element in
      let date = element.timestamp
      let maxDate = date.roundedToMidnight().adding(minutes: measurementIntervalMinutes / 2)
      let minDate = date.roundedToMidnight().adding(minutes: -measurementIntervalMinutes / 2)
      return date >= minDate && date <= maxDate
    }
    let demarcations: [GraphDemarcation] = censusesAroundMidnight.map() {
        index, element in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return GraphDemarcation(title: formatter.string(from: element.timestamp), index: index)
    }
    return demarcations
  }
  
  func generateImage() {
    
    // Avoid drawing the graph when there's no data
    guard !preparedData().isEmpty else {
      return
    }
    
    DispatchQueue.global(qos: .background).async {
      
      let graphGenerator = GraphGenerator(settings: WatchGraphGeneratorSettings())
      
      let data = self.preparedData().map{Double($0.attendance)}
      
      let demarcations = self.preparedDemarcations()
      
        let image = graphGenerator.image(self.contentFrame.size, with: data,
                                         highlight: self.highlightedPointIndex, demarcations: demarcations)
      
      DispatchQueue.main.async {
        self.graphImage.setImage(image)
      }
    }
  }
  
  // Handling interactions
  
  func handleInteraction(_ delta: Double) {
    accumulatedDigitalCrownDelta = 0
    switch interactionMode! {
    case .move:
        var newOffset = offset + delta
        let maxOffset: Double = Double(daysOfRecord) - 1
        let minOffset: Double = 0
        if newOffset > maxOffset {
            newOffset = maxOffset
        } else if newOffset < minOffset {
            newOffset = minOffset
        }
        offset = newOffset
    case .zoom:
        // 1
        var newZoom = zoom + delta
        // 2
        let maxZoom = 3.0
        let minZoom = 0.1
        // 3
        if newZoom > maxZoom {
            newZoom = maxZoom
        } else if newZoom < minZoom {
            newZoom = minZoom
        }
        zoom = newZoom
    case .inspect:
        let direction = delta > 0 ? 1 : -1
        var newIndex = highlightedPointIndex! + direction
        let count = preparedData().count
        if newIndex >= count {
            newIndex = count - 1
        } else if newIndex < 0 {
            newIndex = 0 }
        highlightedPointIndex! = newIndex
    }
    generateImage()
  }
}

extension InterfaceController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        accumulatedDigitalCrownDelta += rotationalDelta
        
        let threshold = 0.05
        guard abs(accumulatedDigitalCrownDelta) > threshold else {
            return
        }
        handleInteraction(accumulatedDigitalCrownDelta)
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        handleInteraction(accumulatedDigitalCrownDelta)
    }
}
