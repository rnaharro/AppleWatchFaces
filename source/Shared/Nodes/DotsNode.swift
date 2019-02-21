//
//  DotsNode ( pac man nodes )
//  AppleWatchFaces
//
//  Created by Michael Hill on 1/24/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class PacNode: SKNode {
    
    func getMouthNode( percent: CGFloat) -> SKNode {
        let triWidth:CGFloat = 9.0
        let triHeight:CGFloat = 8.0 // less = closing mouth
        let triPath = UIBezierPath.init()
        triPath.move(to: CGPoint.init(x: 0, y: 0) )
        triPath.addLine(to: CGPoint.init(x: triWidth, y: triHeight*percent))
        triPath.addLine(to: CGPoint.init(x: triWidth, y: -triHeight*percent))
        triPath.close()
        
        let mouthNode = SKShapeNode.init(path: triPath.cgPath)
        mouthNode.fillColor = SKColor.black
        mouthNode.zPosition = 4.0
        mouthNode.lineWidth = 0.0
        mouthNode.name = "mouth"
        
        return mouthNode
    }
    
    func animateMouth(percent: CGFloat) {
        //debugPrint("animateMouth:" + percent.description)
        if let oldMouthNode = self.childNode(withName: "mouth") {
            oldMouthNode.removeFromParent()
        }
        self.addChild(getMouthNode(percent: percent))
    }
    
    init(radius: CGFloat) {
        super.init()
        
        let circleNode = SKShapeNode.init(circleOfRadius: radius)
        circleNode.fillColor = SKColor.init(hexString: "#ffff04")
        
        self.addChild(circleNode)
        
        let totalTime:CGFloat = 0.75
        let moveMouthAction = SKAction.customAction(withDuration: TimeInterval(Float(totalTime))) {
            node, elapsedTime in
            
            if let node = node as? PacNode {
                let percent = fabs(Double(totalTime/2 - elapsedTime))*2
                
                node.animateMouth(percent: CGFloat(percent))
            }
        }
        let repeatingAction = SKAction.repeatForever(moveMouthAction)
        self.run(repeatingAction)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DotsNode: SKNode {
    
    var numDots: Int = 0
    var secondHandType:SecondHandTypes = .SecondHandNodeTypeNone
    //var forcePacManPos = true
    
    static func rectPath(pathHeight: CGFloat, pathWidth: CGFloat, xOffset: CGFloat) -> UIBezierPath {
        let left = -pathWidth/2
        let right = left + pathWidth
        let top = pathHeight/2
        let bottom = top - pathHeight
        
        let rectPath = UIBezierPath.init()
        rectPath.move(to: CGPoint.init(x: 0 + xOffset, y: top))
        rectPath.addLine(to: CGPoint.init(x: right, y: top))
        rectPath.addLine(to: CGPoint.init(x: right, y: bottom))
        rectPath.addLine(to: CGPoint.init(x: left, y: bottom))
        rectPath.addLine(to: CGPoint.init(x: left, y: top))
        rectPath.close()
        
        return rectPath
    }
    
    func positionHands( sec: CGFloat, secondHandMovement: SecondHandMovements, force: Bool ) {
        
        //TODO: too slow, could be hiding last one unless force=true
        let adjustedHideUpTo = Int(Float(sec) * (Float(numDots)/Float(60)))
        //debugPrint("adj:" + adjustedHideUpTo.description)
        for dot in 0 ... self.numDots-1 {
            if let dotNode = self.childNode(withName: "dot" + String(dot)) {
                if dot >= adjustedHideUpTo {
                    dotNode.isHidden = false
                } else {
                    dotNode.isHidden = true
                }
            }
        }
        
        if let lastDotNode = self.childNode(withName: "dot" + String(adjustedHideUpTo)) {
            //set pacMan position to this position
            if let pacman = self.childNode(withName: "pacMan") {
                
                //dot to turn on
                var cornerNums = [7, 25, 40, 58]
                if secondHandType == .SecondHandTypeMsPacMan {
                    cornerNums = [10, 28, 49, 67]
                }
                
                //point him correctly
                pacman.zRotation = CGFloat(Double.pi*2) // right
                if adjustedHideUpTo>cornerNums[0] { pacman.zRotation = CGFloat(-Double.pi/2) } //down
                if adjustedHideUpTo>cornerNums[1] { pacman.zRotation = CGFloat(Double.pi) } //left
                if adjustedHideUpTo>cornerNums[2] { pacman.zRotation = CGFloat(Double.pi/2) } //up
                if adjustedHideUpTo>cornerNums[3] { pacman.zRotation = CGFloat(Double.pi*2) } //right
                
                if (force || secondHandMovement == .SecondHandMovementStep) {
                    pacman.removeAction(forKey: "moveAction")
                    pacman.position = lastDotNode.position
                } else {
                    let moveAction = SKAction.move(to: lastDotNode.position, duration: 1.0)
                    pacman.run(moveAction, withKey: "moveAction")

                }
     
            }
        }
        
    }
    
    init(pathHeight: CGFloat, pathWidth: CGFloat,
         material: String, strokeColor: SKColor, lineWidth: CGFloat, numDots: Int, secondHandType: SecondHandTypes) {
        
        super.init()
        
        self.secondHandType = secondHandType
        self.numDots = numDots
        
        let rectPath = DotsNode.rectPath(pathHeight: pathHeight, pathWidth: pathWidth, xOffset: 5.0)
        
        let dotSize:CGFloat = 1.75
        for dot in 0 ... self.numDots-1 {
            let percent = CGFloat(Float(dot)/Float(self.numDots))
            let currentPos = rectPath.point(at: percent)
            
            if (dot == 0) {
                //draw pac Man
                let pacNameNode = PacNode.init(radius: 8.0)
                pacNameNode.name = "pacMan"
                pacNameNode.position = currentPos!
                pacNameNode.zPosition = 2.0
                self.addChild(pacNameNode)
                //drawPacMan(pos: currentPos)
            }
            
            
            let newDot = SKShapeNode.init(rect: CGRect.init(x: -dotSize/2, y: -dotSize/2, width: dotSize, height: dotSize))
            newDot.lineWidth = lineWidth
            newDot.fillColor = SKColor.init(hexString: material)
            newDot.strokeColor = strokeColor
            newDot.position = currentPos!
            
            newDot.name = "dot" + String(dot)
            
            self.addChild(newDot)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
