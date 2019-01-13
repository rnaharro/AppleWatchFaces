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

enum DigitalTimeEffects: String {
    case  innerShadow,
    darkInnerShadow,
    dropShadow,
    frame,
    darkFrame,
    roundedFrame,
    None
    
    static let userSelectableValues = [
        innerShadow,
        darkInnerShadow,
        dropShadow,
        frame,
        darkFrame,
        roundedFrame,
        None
    ]
}

class DigitalTimeNode: SKNode {
    var timeFormat: DigitalTimeFormats = .DD
    
    func updateTime( timeString: String ) {
        
        if let timeText = self.childNode(withName: "timeTextNode") as? SKLabelNode {
            //let mutableAttributedString = NSMutableAttributedString(string: timeString, attributes: myAttributes)
            let mutableAttributedText = timeText.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeText.attributedText = mutableAttributedText
        }
        if let timeTextShadow = self.childNode(withName: "textShadow") as? SKLabelNode {
            //let mutableAttributedString = NSMutableAttributedString(string: timeString, attributes: myAttributes)
            let mutableAttributedText = timeTextShadow.attributedText!.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(timeString)
            
            timeTextShadow.attributedText = mutableAttributedText
            timeTextShadow.isHidden = false
        }
    }
    
    func setToTime() {
        setToTime(force: false)
    }
    
    func setToTime(force: Bool) {
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
        
        //EXIT EARLY DEPENDING ON TYPE -- only move forward (do the update ) once per minute
        if (timeFormat != .HHMMSS && seconds != 0 && force == false) {
            return
        }
        
        let monthString = calendar.shortMonthSymbols[calendar.component(.month, from: date)-1]
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
            timeString = " " //empty can cause crash on calcuating size  (calculateAccumulatedFrame)
        }
        
        updateTime(timeString: timeString)
    }
    
    //used when generating node for digital time ( a mini digital clock )
    init(digitalTimeTextType: NumberTextTypes, timeFormat: DigitalTimeFormats, textSize: Float, effect: DigitalTimeEffects, horizontalPosition: RingHorizontalPositionTypes, fillColor: SKColor, strokeColor: SKColor? ) {
    
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
        
        //needs to always come BEFORE calculateAccumulatedFrame since it will adjust the width
        setToTime(force: true) //update to latest time to start
        
        //get boudary for adding frames
        let labelRect = timeText.calculateAccumulatedFrame()
        //re-use "dark color" for backgrounds
        let darkColor = SKColor.black.withAlphaComponent(0.4)
        //re-use an expanded frame
        let buffer:CGFloat = labelRect.height/2 //how much in pixels to expand the rectagle to draw the shadow past the text label
        let expandedRect = labelRect.insetBy(dx: -buffer, dy: -buffer)

        if (effect == .frame || effect == .darkFrame) {
            let frameNode = SKShapeNode.init(rect: expandedRect)
            frameNode.lineWidth = 2.0
            frameNode.strokeColor = fillColor
            
            if (effect == .darkFrame) {
                frameNode.fillColor = darkColor
            }
            
            self.addChild(frameNode)
        }
        
        if (effect == .roundedFrame) {
            let frameNode = SKShapeNode.init(rect: expandedRect, cornerRadius: labelRect.height/3)
            frameNode.lineWidth = 2.0
            frameNode.strokeColor = fillColor
            
            if (effect == .darkFrame) {
                frameNode.fillColor = darkColor
            }
            
            self.addChild(frameNode)
        }
        
        if (effect == .dropShadow) {
            let shadowNode = timeText.copy() as! SKLabelNode
            shadowNode.name = "textShadow"
            let shadowColor = SKColor.black.withAlphaComponent(0.4)
            var attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: shadowColor,
                .font: UIFont.init(name: fontName, size: CGFloat( Float(textSize) / textScale ))!
            ]
            if strokeColor != nil {
                attributes[.strokeWidth] = round(strokeWidth)
                attributes[.strokeColor] = strokeColor
            }
            shadowNode.attributedText = NSAttributedString(string: hourString, attributes: attributes)
            shadowNode.zPosition = -0.5
            let shadowOffset = CGFloat(labelRect.size.height/10)
            shadowNode.position = CGPoint.init(x: timeText.position.x+shadowOffset, y: timeText.position.y-shadowOffset)
            shadowNode.isHidden = true
            self.addChild(shadowNode)
        }
        
        if (effect == .innerShadow || effect == .darkInnerShadow) {
            let shadowNode = SKNode.init()
            shadowNode.name = "shadowNode"
            
            let shadowHeight:CGFloat = labelRect.height/3
            
            let shadowTexture = SKTexture.init(imageNamed: "dark-shadow.png")
            
            let topShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.width, height: shadowHeight))
            topShadowNode.position = CGPoint.init(x: 0, y: expandedRect.height/2 - shadowHeight/2)
            shadowNode.addChild(topShadowNode)
            
            let bottonShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.width, height: shadowHeight))
            bottonShadowNode.position = CGPoint.init(x: 0, y: -expandedRect.height/2 + shadowHeight/2)
            bottonShadowNode.zRotation = CGFloat.pi
            shadowNode.addChild(bottonShadowNode)

            let leftShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.height, height: shadowHeight))
            leftShadowNode.position = CGPoint.init(x: -expandedRect.width/2 + shadowHeight/2, y: 0)
            leftShadowNode.zRotation = CGFloat.pi/2
            shadowNode.addChild(leftShadowNode)
            
            let rightShadowNode = SKSpriteNode.init(texture: shadowTexture, color: SKColor.clear, size: CGSize.init(width: expandedRect.height, height: shadowHeight))
            rightShadowNode.position = CGPoint.init(x: expandedRect.width/2 - shadowHeight/2, y: 0)
            rightShadowNode.zRotation = -CGFloat.pi/2
            shadowNode.addChild(rightShadowNode)
            
            //reverse center for text rendering
            switch horizontalPosition {
            case .Left:
                shadowNode.position = CGPoint.init(x: labelRect.width/2, y: 0)
            case .Right:
                shadowNode.position = CGPoint.init(x: -labelRect.width/2, y: 0)
            default:
                shadowNode.position = CGPoint.init(x: 0, y: 0)
            }
            
            if (effect == .darkInnerShadow) {
                let frameNode = SKShapeNode.init(rect: expandedRect)
                frameNode.fillColor = darkColor
                frameNode.lineWidth = 0.0
                
                self.addChild(frameNode)
            }
            
            timeText.addChild(shadowNode)
        }
        
        //ONE MORE TIME TO UPDATE ANY NEW ADDITIONS IN EFFECTS
        setToTime(force: true) //update to latest time to start
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSecondsChanged(notification:)), name: SKWatchScene.timeChangedSecondNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onNotificationForSecondsChanged(notification:Notification) {
        setToTime()
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
    
    static func descriptionForTimeEffects(_ format: DigitalTimeEffects) -> String {
        var description = ""
        
        switch format {
        case .darkFrame:
            description = "Dark Frame"
        case .darkInnerShadow:
            description = "Dark Inner Shadow"
        case .dropShadow:
            description = "Drop Shadow"
        case .frame:
            description = "Frame"
        case .roundedFrame:
            description = "Rounded Frame"
        case .innerShadow:
            description = "Inner Shadow"
        default:
            description = "None"
        }
        
        return description
    }
    
    static func timeEffectsDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in DigitalTimeFormats.userSelectableValues {
            typeDescriptionsArray.append(descriptionForTimeFormats(nodeType))
        }
        
        return typeDescriptionsArray
    }

}
