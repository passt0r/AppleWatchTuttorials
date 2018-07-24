/*
* Copyright (c) 2015 Razeware LLC
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
    @IBOutlet var timer: WKInterfaceTimer!
    
    @IBOutlet var temleratureLabel: WKInterfaceLabel!
    @IBOutlet var timerButton: WKInterfaceButton!
    @IBOutlet var weightPicker: WKInterfacePicker!
    @IBOutlet var temperaturePicker: WKInterfacePicker!
    
    var ounces = 16
    var cookTemp = MeatTemperature.medium
    var timerRunning = false
    
    @IBAction func onTimerButton() {
        if timerRunning {
            timer.stop()
            timer.setDate(Date())
            timerButton.setTitle("Start Timer")
        } else {
           let time = cookTemp.cookTimeForOunces(ounces)
            timer.setDate(Date(timeIntervalSinceNow: time))
            timer.start()
            timerButton.setTitle("Stop Timer")
        }
        timerRunning = !timerRunning
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        var weightItems: [WKPickerItem] = []
        for i in 1...32 {
            let item = WKPickerItem()
            item.title = String(i)
            weightItems.append(item)
        }
        weightPicker.setItems(weightItems)
        weightPicker.setSelectedItemIndex(ounces - 1)
        
        var tempItems: [WKPickerItem] = []
        for i in 1...4 {
            let item = WKPickerItem()
            item.contentImage = WKImage(imageName: "temp-\(i)")
            tempItems.append(item)
        }
        temperaturePicker.setItems(tempItems)
        onTemperatureChanged(0)
    }
    @IBAction func onWeightChanged(_ value: Int) {
        ounces = value + 1
    }
    
    @IBAction func onTemperatureChanged(_ value: Int) {
        let temp = MeatTemperature(rawValue: value)!
        cookTemp = temp
        temleratureLabel.setText(temp.stringValue)
    }
    
}
