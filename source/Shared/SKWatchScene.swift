//
//  SKWatchScene.swift
//  Face Extension
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import SpriteKit

class SKWatchScene: SKScene {
    static let sizeMulitplier:CGFloat = 100.0 //in pixels
    
    static let timeForceUpdateNotificationName = Notification.Name("timeForceUpdate")
    
    func redraw(clockSetting: ClockSetting) {
        
        let newWatchFaceNode = WatchFaceNode.init(clockSetting: clockSetting, size: self.size )
        newWatchFaceNode.setScale(1.375)
        
        if let oldNode = self.childNode(withName: "watchFaceNode") {
            oldNode.removeFromParent()
        }
        
        newWatchFaceNode.setToTime( force: true )
        self.addChild(newWatchFaceNode)
    }
    
    func forceToTime() {
        if let oldNode = self.childNode(withName: "watchFaceNode") as? WatchFaceNode {
            oldNode.setToTime( force: true )
            //send this notification to get any digital time decorators to update thier time
            NotificationCenter.default.post(name: SKWatchScene.timeForceUpdateNotificationName, object: nil, userInfo:nil)
        }
    }
    
    func cleanup() {
        //NotificationCenter.default.removeObserver(self)
        if let watchFaceNode = self.childNode(withName: "watchFaceNode") as? WatchFaceNode {
            watchFaceNode.removeFromParent()
        }
    }
    
    override func sceneDidLoad() {
        //redraw( clockSetting: ClockSetting.defaults() )
        //check to see if we need to update time every second
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSecondsChanged(notification:)), name: ClockTimer.timeChangedSecondNotificationName, object: nil)
    }
    
    @objc func onNotificationForSecondsChanged(notification:Notification) {
        //debugPrint("second hand movement action")
        
        if let watchFaceNode = self.childNode(withName: "watchFaceNode") as? WatchFaceNode {
            watchFaceNode.setToTime()
        }
    }
    
}
