//  FaceBackgroundColorSettingTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/29/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FaceBackgroundColorSettingTableViewCell: ColorSettingsTableViewCell {
    
    @IBOutlet var faceBackgroundColorSelectionCollectionView: UICollectionView!
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorList.count+1
    }
    
    // called after a new setting should be selected ( IE a new design is loaded )
    override func chooseSetting( animated: Bool ) {
        //debugPrint("** FaceBackgroundColorSettingTableViewCell called **" + SettingsViewController.currentClockSetting.clockFaceMaterialName)
    
        let filteredColor = colorListVersion(unfilteredColor: SettingsViewController.currentClockSetting.clockFaceMaterialName)
        if let materialColorIndex = colorList.firstIndex(of: filteredColor) {
            let indexPath = IndexPath.init(row: materialColorIndex, section: 0)

            //scroll and set native selection
            faceBackgroundColorSelectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var newColor = ""
        
        //special hack for camera
        if (indexPath.row == colorList.count) {
            NotificationCenter.default.post(name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil, userInfo:nil)
            return //exit now in case user cancels camera selection ( and wants to keep old setting 
        } else {
             newColor = colorList[indexPath.row]
        }
        
        debugPrint("selected cell faceBackgroundColor: " + newColor)
        
        //update the value
        SettingsViewController.currentClockSetting.clockFaceMaterialName = newColor
        NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
        NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                        userInfo:["cellId": self.cellId , "settingType":"clockFaceMaterialName"])
    }
    
}
