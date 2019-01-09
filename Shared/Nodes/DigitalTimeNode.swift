//
//  HourTextNodeNode.swift
//  AppleWatchFaces
//
//  Created by Mike Hill on 11/11/15.
//  Copyright © 2015 Mike Hill. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import Foundation

enum DigitalTimeVerticalPositionTypes: String {
    case Top,
    Centered,
    Bottom
}

enum DigitalTimeHorizontalPositionTypes: String {
    case Left,
    Centered,
    Right
}

class DigitalTimeNode: SKNode {
    
    var secondHandTimer = Timer()
    var currentSecond : Int = -1
    
    func updateTime( sec: CGFloat, min: CGFloat, hour: CGFloat ) {
        
        let hourString = String(format: "%02d", Int(hour))
        let minString = String(format: "%02d", Int(min))
        let secString = String(format: "%02d", Int(sec))
        
        let timeString = hourString + ":" + minString + ":" + secString
        
        if let timeText = self.childNode(withName: "timeTextNode") as? SKLabelNode {
            //let mutableAttributedString = NSMutableAttributedString(string: timeString, attributes: myAttributes)
            let mutableAttributedText = timeText.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeText.attributedText = mutableAttributedText
        }
    }
    
    func setToTime() {
        // Called before each frame is rendered
        let date = Date()
        let calendar = Calendar.current
        
        let hour = CGFloat(calendar.component(.hour, from: date))
        let minutes = CGFloat(calendar.component(.minute, from: date))
        let seconds = CGFloat(calendar.component(.second, from: date))
        
        updateTime(sec: seconds, min: minutes, hour: hour)
    }
    
    //used when generating node for digital time ( a mini digital clock )
    init(digitalTimeTextType: NumberTextTypes, textSize: Float, horizontalPosition: DigitalTimeHorizontalPositionTypes, verticalPosition: DigitalTimeVerticalPositionTypes,
         fillColor: SKColor, strokeColor: SKColor? ) {
        
        super.init()

        self.name = "digitalTimeNode"
        
        //TODO this should dependant on overall scale setting?
        let textScale = Float(0.0175)
        let hourString = "00:00:00"
        
        let timeText = SKLabelNode.init(text: hourString)
        timeText.name = "timeTextNode"
        timeText.horizontalAlignmentMode = .center
        timeText.verticalAlignmentMode = .center
        
        let fontName = NumberTextNode.fontNameForNumberTextType(digitalTimeTextType)
        
        //attributed version
        let strokeWidth = -2 * textSize
        //debugPrint("strokeW: " + strokeWidth.description)

        var attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: fillColor,
                .font: UIFont.init(name: fontName, size: CGFloat( Float(textSize) / textScale ))!
            ]
        if strokeColor != nil {
            attributes[.strokeWidth] = round(strokeWidth)
            attributes[.strokeColor] = strokeColor
        }
        timeText.attributedText = NSAttributedString(string: hourString, attributes: attributes)

        self.addChild(timeText)
        
        let duration = 0.1
        self.secondHandTimer = Timer.scheduledTimer( timeInterval: duration, target:self, selector: #selector(DigitalTimeNode.secondHandMovementCheck), userInfo: nil, repeats: true)
    }
    
    @objc func secondHandMovementCheck() {
        let date = Date()
        let calendar = Calendar.current
        
        let seconds = Int(calendar.component(.second, from: date))
        
        if (self.currentSecond != seconds) {
            setToTime()
            self.currentSecond = seconds
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
