//
//  WatchPreviewViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/28/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

class WatchPreviewViewController: UIViewController {

    @IBOutlet var skView: SKView!
    
    func stopTimeForScreenShot() {
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.stopTimeForScreenShot()
        }
    }
    
    func resumeTime() {
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.resumeTime()
        }
    }
    
    func makeThumb( imageName:String, cornerCrop: Bool ) -> Bool {
        //let newView = skView.snapshotView(afterScreenUpdates: true)
        if let newImage = skView?.snapshot {
            return newImage.save(imageName: imageName, cornerCrop: cornerCrop)
        } else {
            return false
        }
    }
    
    func redraw() {
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.redraw(clockSetting: SettingsViewController.currentClockSetting)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
                switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    print("Swiped right")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"prevClock"])
                    //settingsViewController?.prevClock()
                case UISwipeGestureRecognizer.Direction.left:
                    print("Swiped left")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"nextClock"])
                    //settingsViewController?.nextClock()
                case UISwipeGestureRecognizer.Direction.up:
                    print("Swiped up")
                    NotificationCenter.default.post(name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil, userInfo:["action":"sendSetting"])
                    //settingsViewController?.sendSettingAction(sender: UIButton() )
                default:
                    break
                }
        }
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        
        // force watch to correct time without any animation after resuming
        //  https://github.com/orff/AppleWatchFaces/issues/12
        if let watchScene = skView.scene as? SKWatchScene {
            watchScene.forceToTime()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //make the watch frame look
        skView.layer.cornerRadius = AppUISettings.watchFrameCornerRadius
        skView.layer.borderWidth = AppUISettings.watchFrameBorderWidth
        skView.layer.borderColor = AppUISettings.watchFrameBorderColor
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(WatchPreviewViewController.respondToSwipeGesture(gesture:) ))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
        
        // Load the SKScener
        if let scene = SKWatchScene(fileNamed: "SKWatchScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            skView.presentScene(scene)
        }
        
        //debug options
        skView.showsFPS = false
        skView.showsNodeCount = false
    
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

}
