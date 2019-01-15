//
//  DecoratorTableViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/2/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class DecoratorSpacerTableViewCell: DecoratorTableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueSlider: UISlider!
    
//    override func transitionToEditMode() {
//        self.valueSlider.isHidden = true
//    }
//    
//    override func transitionToNormalMode() {
//        self.valueSlider.isHidden = false
//    }
    
    @IBAction func sliderValueDidChange(sender: UISlider ) {
        //debugPrint("slider value:" + String( sender.value ) )
        let clockRingSetting = myClockRingSetting()
        
        let roundedValue = Float(round(50*sender.value)/50)
        if roundedValue != clockRingSetting.ringWidth {
            self.selectThisCell()
            clockRingSetting.ringWidth = roundedValue
            NotificationCenter.default.post(name: DecoratorPreviewController.ringSettingsChangedNotificationName, object: nil,
                                        userInfo:["settingType":"ringWidth" ])
        }
    }
    
    override func setupUIForClockRingSetting( clockRingSetting: ClockRingSetting ) {
        super.setupUIForClockRingSetting(clockRingSetting: clockRingSetting)
    
        self.titleLabel.text = ClockRingSetting.descriptionForRingType(clockRingSetting.ringType)
        
        valueSlider.minimumValue = AppUISettings.ringSettigsSliderSpacerMin
        valueSlider.maximumValue = AppUISettings.ringSettigsSliderSpacerMax
            
        valueSlider.value = clockRingSetting.ringWidth
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
