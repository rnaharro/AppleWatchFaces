//
//  FaceShapeSettingCollectionViewCell.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/28/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class FaceShapeSettingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnail : UIImageView!
    var shapeLayer:CAShapeLayer? = nil
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                if let shapeLayer = shapeLayer {
                        let color = AppUISettings.settingHighlightColor
                        shapeLayer.strokeColor = SKColor.init(hexString: color).cgColor
                }
            } else {
                if let shapeLayer = shapeLayer {
                    shapeLayer.strokeColor = SKColor.clear.cgColor
                }
            }
            
        }
    }
}

