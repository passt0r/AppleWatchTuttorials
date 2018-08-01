//
//  ColorController.swift
//  ColorPicker WatchKit Extension
//
//  Created by Dmytro Pasinchuk on 8/1/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import WatchKit
import Foundation


class ColorController: WKInterfaceController {
    @IBOutlet var backgroundGroup: WKInterfaceGroup!
    @IBOutlet var label: WKInterfaceLabel!
    
    var activeColor = UIColor.white
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let color = context as? UIColor {
            update(color: color)
        }
        // Configure interface objects here.
    }
    
    override func didAppear() {
        super.didAppear()
        updateSelectedColor()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func update(color: UIColor) {
        activeColor = color
        backgroundGroup.setBackgroundColor(color)
        label.setText("#" + color.hexString)
    }
    
    private func updateSelectedColor() {
        ColorManager.defaultManager.selectedColor = activeColor
    }
    
    @IBAction private func onDarken() {
        update(color: activeColor.darkerColor())
        updateSelectedColor()
    }
    @IBAction private func onLighten() {
        update(color: activeColor.lighterColor())
        updateSelectedColor()
    }

}
