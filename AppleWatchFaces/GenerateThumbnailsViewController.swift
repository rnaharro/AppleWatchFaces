//
//  GenerateThumbnailsViewController.swift
//  AppleWatchFaces
//
//  Created by Hill, Michael on 1/30/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class GenerateThumbnailsViewController: UIViewController {

    @IBOutlet var skView: SKView!
    var settingsWithoutThumbs:[ClockSetting] = []
    //used when generating thumbnails / etc
    var timerClockIndex = 0
    var timer = Timer()
    
    func makeThumb( fileName: String) {
        _ = makeThumb(imageName: fileName, cornerCrop: false)
    }
    
    func makeThumb( imageName:String, cornerCrop: Bool ) -> Bool {
        //let newView = skView.snapshotView(afterScreenUpdates: true)
        if let newImage = skView?.snapshot {
            return newImage.save(imageName: imageName, cornerCrop: cornerCrop)
        } else {
            return false
        }
    }
    
    // called every time interval from the timer
    @objc func screenshotThumbActionFromTimer() {
        
        if (timerClockIndex < settingsWithoutThumbs.count) {
            
            let setting = settingsWithoutThumbs[timerClockIndex]
            if let watchScene = skView.scene as? SKWatchScene {
                watchScene.redraw(clockSetting: setting)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.makeThumb(fileName: setting.uniqueID)
            })
            
            timerClockIndex += 1
            
        } else {
            timer.invalidate()
            
            //self.showMessage( message: "finished screenshots.")
            self.dismiss(animated: true) {
                //
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the SKScene
        if let scene = SKWatchScene(fileNamed: "SKWatchScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            skView.presentScene(scene)
        }
        
        //debug options
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        settingsWithoutThumbs = UserClockSetting.settingsWithoutThumbNails()
        if settingsWithoutThumbs.count == 0 {
            // generate all !
            settingsWithoutThumbs = UserClockSetting.sharedClockSettings
        }
        
        //redraw missing
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.stopTimeForScreenShot()
        }
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(screenshotThumbActionFromTimer), userInfo: nil, repeats: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
