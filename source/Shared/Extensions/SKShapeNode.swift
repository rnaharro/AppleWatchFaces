//
//  SKShapeNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//
import SpriteKit

extension SKShapeNode {

    func setMaterial( material: String ) {
        if AppUISettings.materialIsColor(materialName: material) {
            self.fillColor = SKColor.init(hexString: material)
        } else {
            if let image = UIImage.init(named: material) {
                self.fillTexture = SKTexture.init(image: image)
                self.fillColor = SKColor.white
            } else {
                // try for docs loading
                if let image = UIImage.getImageFor(imageName: material)  {
                    self.fillTexture = SKTexture.init(image: image)
                    self.fillColor = SKColor.white
                }
            }
        }
    }

}
