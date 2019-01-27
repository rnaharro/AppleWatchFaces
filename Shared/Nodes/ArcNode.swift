//
//  ArcNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 1/24/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class ArcNode: SKNode {

    static let fatRadiusWidth:CGFloat = 30.0 //difference between inner and out radius
    static let skinnyRadiusWidth:CGFloat = 15.0 //difference between inner and out radius
    
    static func filledShapeNode(material: String) -> SKShapeNode {
        let sizeMultiplier = CGFloat(SKWatchScene.sizeMulitplier)
        
        let w = CGFloat( CGFloat(3.12) / 1.425 )
        let h = CGFloat( CGFloat(3.9)  / 1.425 )
        let shape = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: w * sizeMultiplier, height: h * sizeMultiplier))
        shape.setMaterial(material: material)
        shape.position = CGPoint.init(x: -(w * sizeMultiplier)/2, y: -(h * sizeMultiplier)/2)
        return shape
    }
    
    init(cornerRadius: CGFloat, innerRadius: CGFloat, outerRadius: CGFloat, endAngle: CGFloat,
         material: String, strokeColor: SKColor, lineWidth: CGFloat) {
        
        super.init()
        
        let cornerRadius:CGFloat = cornerRadius //8.0 //how rounded the edges are, but also how far from edges
        let innerRadius:CGFloat = innerRadius //90.0
        let outerRadius:CGFloat = outerRadius //110.0
        let initalAngleforTop = CGFloat(Double.pi * 0.5)
        let startAngle:CGFloat = initalAngleforTop
        let endAngle:CGFloat = CGFloat(Double.pi * 0.5) - endAngle //self.zRotation // CGFloat(Double.pi * 1.0)
        let center = CGPoint(x: 0, y: 0)
        
        let innerTheta = asin(cornerRadius / 2.0 / (innerRadius + cornerRadius)) * 2.0
        let outerTheta = asin(cornerRadius / 2.0 / (outerRadius - cornerRadius)) * 2.0
        
        let circlePath = UIBezierPath(arcCenter: center, radius: innerRadius + cornerRadius,
                                      startAngle: endAngle - innerTheta, endAngle: startAngle + innerTheta, clockwise: false)
        circlePath.addArc(withCenter: center, radius: outerRadius - cornerRadius, startAngle: startAngle + outerTheta, endAngle: endAngle - outerTheta, clockwise: true)
        circlePath.apply(CGAffineTransform.init(scaleX: -1, y: 1)) //flip
        circlePath.close()
        
        let shape = SKShapeNode.init(path: circlePath.cgPath)
        shape.name = "arcShape"
        shape.position = CGPoint.init(x: 0, y: 0.0)
        
        if AppUISettings.materialIsColor(materialName: material) {
            shape.fillColor = SKColor.init(hexString: material)
            shape.strokeColor = strokeColor
            shape.lineWidth = lineWidth //how thick the edges are to show rounded corner
            
            self.addChild(shape)
        } else {
            //has image, mask into shape!
            shape.fillColor = SKColor.white
            
            let cropNode = SKCropNode()
            cropNode.name = "arcShape"
            let filledNode = ArcNode.filledShapeNode(material: material)
            cropNode.addChild(filledNode)
            cropNode.maskNode = shape
            
            self.addChild(cropNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
