//
//  FaceBackgroundNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import SpriteKit
import SceneKit

enum FaceBackgroundTypes: String {
    case FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit, FaceBackgroundTypeCircle, FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeNone
    
    static let randomizableValues = [FaceBackgroundTypeCircle, FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit,
        FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeNone]
    static let userSelectableValues = [FaceBackgroundTypeFilled, FaceBackgroundTypeDiagonalSplit, FaceBackgroundTypeCircle,
        FaceBackgroundTypeVerticalSplit, FaceBackgroundTypeHorizontalSplit, FaceBackgroundTypeNone]
    
    static func random() -> FaceBackgroundTypes {
        let randomIndex = Int(arc4random_uniform(UInt32(randomizableValues.count)))
        return randomizableValues[randomIndex]
    }
}

class FaceBackgroundNode: SKSpriteNode {
    
    static func descriptionForType(_ nodeType: FaceBackgroundTypes) -> String {
        var typeDescription = ""
        
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeCircle)  { typeDescription = "Circle" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeFilled)  { typeDescription = "Filled" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit)  { typeDescription = "Split Diagonal" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeVerticalSplit)  { typeDescription = "Vertical Split" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalSplit)  { typeDescription = "Horizonatal Split" }
        if (nodeType == FaceBackgroundTypes.FaceBackgroundTypeNone)  { typeDescription = "None" }
        
        return typeDescription
    }
    
    static func typeDescriptions() -> [String] {
        var typeDescriptionsArray = [String]()
        for nodeType in FaceBackgroundTypes.userSelectableValues {
            typeDescriptionsArray.append(descriptionForType(nodeType))
        }
        
        return typeDescriptionsArray
    }
    
    static func typeKeys() -> [String] {
        var typeKeysArray = [String]()
        for nodeType in FaceBackgroundTypes.userSelectableValues {
            typeKeysArray.append(nodeType.rawValue)
        }
        
        return typeKeysArray
    }
    
    static func filledShapeNode(material: String) -> SKShapeNode {
        let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
        
        let w = CGFloat( CGFloat(3.20) / 1.4 )// / 1.425
        let h = CGFloat( CGFloat(3.9)  / 1.4 )// / 1.425
        let shape = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: w * sizeMultiplier, height: h * sizeMultiplier))
        shape.setMaterial(material: material)
        shape.position = CGPoint.init(x: -(w * sizeMultiplier)/2, y: -(h * sizeMultiplier)/2)
        return shape
    }
    
    convenience init(backgroundType: FaceBackgroundTypes, material: String) {
        self.init(backgroundType: backgroundType, material: material, strokeColor: SKColor.clear, lineWidth: 1.0)
    }
    
    init(backgroundType: FaceBackgroundTypes, material: String, strokeColor: SKColor, lineWidth: CGFloat ) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize.init())
        
        self.name = "FaceBackground"
        let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
        let xBounds = 320 / 2.8
        let yBounds = 390 / 2.8
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeFilled) {
            let shape = FaceBackgroundNode.filledShapeNode(material: material)
            self.addChild(shape)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeDiagonalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xBounds, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            shape.setMaterial(material: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth
            
            self.addChild(shape)
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeVerticalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: yBounds))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: 0, y: -yBounds))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                //has image, mask into shape!
                shape.fillColor = SKColor.white
                
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                cropNode.maskNode = shape
                self.addChild(cropNode)
            }
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeHorizontalSplit) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xBounds, y: 0))
            bezierPath.addLine(to: CGPoint(x: xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: -yBounds))
            bezierPath.addLine(to: CGPoint(x: -xBounds, y: 0))
            bezierPath.close()
            
            let shape = SKShapeNode.init(path: bezierPath.cgPath)
            
            if AppUISettings.materialIsColor(materialName: material) {
                shape.fillColor = SKColor.init(hexString: material)
                shape.strokeColor = strokeColor
                shape.lineWidth = lineWidth
                self.addChild(shape)
            } else {
                //has image, mask into shape!
                shape.fillColor = SKColor.white
                
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                cropNode.maskNode = shape
                self.addChild(cropNode)
            }
        
        }
        
        if (backgroundType == FaceBackgroundTypes.FaceBackgroundTypeCircle) {
            
            let r = CGFloat(1.1)
            let circleNode = SKShapeNode.init(circleOfRadius: r * sizeMultiplier)
            
            if AppUISettings.materialIsColor(materialName: material) {
                //draw it as a shape, no background!
                circleNode.fillColor = SKColor.init(hexString: material)
                circleNode.strokeColor = strokeColor
                circleNode.lineWidth = lineWidth
                self.addChild(circleNode)
            } else {
                //has image, mask into shape!
                let cropNode = SKCropNode()
                let filledNode = FaceBackgroundNode.filledShapeNode(material: material)
                cropNode.addChild(filledNode)
                circleNode.fillColor = SKColor.white
                cropNode.maskNode = circleNode
                self.addChild(cropNode)
            }
            
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
