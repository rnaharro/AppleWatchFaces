//
//  FaceShapeSettingSettingsTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/28/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FaceShapeSettingSettingsTableViewCell: WatchSettingsSelectableTableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var faceShapeSettingCollectionView: UICollectionView!
    
    //var selectedCellIndex:Int?
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        //debugPrint("** SecondHandSettingsTableViewCell called **")
        
        if let currentShape = SettingsViewController.currentClockSetting.clockFaceSettings?.ringRenderShape {
            if let shapeIndex = RingRenderShapes.userSelectableValues.firstIndex(of: currentShape) {
                let indexPath = IndexPath.init(row: shapeIndex, section: 0)

                //scroll and set native selection
                faceShapeSettingCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)
            } else {
                faceShapeSettingCollectionView.deselectAll(animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let renderShape = RingRenderShapes.userSelectableValues[indexPath.row]
        //debugPrint("selected cell SecondHandMovements: " + secondHandMovement.rawValue)

        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        //update the value
        SettingsViewController.currentClockSetting.clockFaceSettings?.ringRenderShape = renderShape
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"ringRenderShape"])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RingRenderShapes.userSelectableValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsFaceShapeCell", for: indexPath) as! FaceShapeSettingCollectionViewCell
        
        let shape = RingRenderShapes.userSelectableValues[indexPath.row]
        
        //design path in layer
        cell.shapeLayer = CAShapeLayer()
        let shapeLayer = cell.shapeLayer!
        let path = WatchFaceNode.getShapePath( ringRenderShape: shape )
    
        path.apply(CGAffineTransform.init(scaleX: 0.225, y: 0.225))  //scale/stratch
        path.apply(CGAffineTransform.init(translationX: 50.0, y: 58.0)) //repos
        
        let fillColor = SKColor.init(hexString: "#ddddddff")
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = SKColor.white.cgColor
        
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = 4.0
        
        cell.layer.addSublayer(shapeLayer)
        
        return cell
    }
}

