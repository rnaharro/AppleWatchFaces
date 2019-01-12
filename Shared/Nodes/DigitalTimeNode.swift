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

enum DigitalTimeFormats: String {
    case HHMMSS,
    HHMM,
    DDMM,
    MMDD,
    DD,
    None
    
    static let userSelectableValues = [
        DD,
        MMDD,
        DDMM,
        HHMM,
        HHMMSS
    ]
}

class DigitalTimeNode: SKNode {
    
    var secondHandTimer = Timer()
    var currentSecond : Int = -1
    var timeFormat: DigitalTimeFormats = .DD
    
    func updateTime( timeString: String ) {
        
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
//        let formatter = DateFormatter()
//        let monthComponents = formatter.shortMonthSymbols
        
        //let month = CGFloat(calendar.component(.month, from: date))
        let day = CGFloat(calendar.component(.day, from: date))
        
        let hour = CGFloat(calendar.component(.hour, from: date))
        let minutes = CGFloat(calendar.component(.minute, from: date))
        let seconds = CGFloat(calendar.component(.second, from: date))
        
        let monthString = calendar.shortMonthSymbols[calendar.component(.month, from: date)]
        //let monthNumString = String(format: "%02d", Int(month))
        let dayString = String(format: "%02d", Int(day))
        
        let hourString = String(format: "%02d", Int(hour))
        let minString = String(format: "%02d", Int(minutes))
        let secString = String(format: "%02d", Int(seconds))
        
        var timeString = ""
        switch timeFormat {
        case .DD:
            timeString = dayString
        case .DDMM:
            timeString = dayString + " " + monthString
        case .MMDD:
            timeString = monthString + " " + dayString
        case .HHMM:
            timeString = hourString + ":" + minString
        case .HHMMSS:
            timeString = hourString + ":" + minString + ":" + secString
        default:
            timeString = ""
        }
        
        updateTime(timeString: timeString)
    }
    
    //used when generating node for digital time ( a mini digital clock )
    init(digitalTimeTextType: NumberTextTypes, timeFormat: DigitalTimeFormats, textSize: Float, horizontalPosition: RingHorizontalPositionTypes, fillColor: SKColor, strokeColor: SKColor? ) {
    
        super.init()

        self.name = "digitalTimeNode"
        self.timeFormat = timeFormat
        
        //TODO this should dependant on overall scale setting?
        let textScale = Float(0.0175)
        let hourString = DigitalTimeNode.descriptionForTimeFormats(timeFormat)
        
        let timeText = SKLabelNode.init(text: hourString)
        timeText.name = "timeTextNode"
        
        switch horizontalPosition {
        case .Left:
            timeText.horizontalAlignmentMode = .left
        case .Right:
            timeText.horizontalAlignmentMode = .right
        default:
            timeText.horizontalAlignmentMode = .center
        }
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
        
        setToTime()
        
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
    
    static func descriptionForTimeFormats(_ format: DigitalTimeFormats) -> String {
        var description = ""
        
        switch format {
        case .DD:
            description = "DD"
        case .DDMM:
            description = "DD&MO"
        case .MMDD:
            description = "MO&DD"
        case .HHMM:
            description = "HH:MM"
        default:
            description = "None"
        }
        
//        if (format == DigitalTimeFormats.DD)  { description = "Day" }
//        if (format == DigitalTimeFormats.DDMM)  { description = "Day & Month" }
//        if (format == DigitalTimeFormats.MMDD)  { description = "Month & Day" }
//        if (format == DigitalTimeFormats.HHMM)  { description = "Hour:Minute" }
//        if (format == DigitalTimeFormats.HHMMSS)  { description = "Hour:Minute:Second" }
//        if (format == DigitalTimeFormats.None)  { description = "None" }
        
        return description
    }
    
    static func timeFormatsDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeDescriptionsArray.append(descriptionForTimeFormats(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func timeFormatsKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }

}
