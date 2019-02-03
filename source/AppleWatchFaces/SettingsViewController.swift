//
//  ViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit
import WatchConnectivity

class SettingsViewController: UIViewController, WCSessionDelegate {

    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    @IBOutlet var groupSegmentControl: UISegmentedControl!
    
    var session: WCSession?
    weak var watchPreviewViewController:WatchPreviewViewController?
    weak var watchSettingsTableViewController:WatchSettingsTableViewController?
    
    static var currentClockSetting: ClockSetting = ClockSetting.defaults()
    var currentClockIndex = 0
    static var undoArray = [ClockSetting]()
    static var redoArray = [ClockSetting]()
    
    static let settingsChangedNotificationName = Notification.Name("settingsChanged")
    static let settingsGetCameraImageNotificationName = Notification.Name("getBackgroundImageFromCamera")
    static let settingsPreviewSwipedNotificationName = Notification.Name("swipedOnPreview")
    
    func showError( errorMessage: String) {
        DispatchQueue.main.async {
            self.showToast(message: errorMessage, color: UIColor.red)
        }
    }
    
    func showMessage( message: String) {
        DispatchQueue.main.async {
            self.showToast(message: message, color: UIColor.lightGray)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //debugPrint("session activationDidCompleteWith")
        showMessage( message: "Watch session active")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //debugPrint("session sessionDidBecomeInactive")
        showError(errorMessage: "Watch session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        //debugPrint("session sessionDidDeactivate")
        showError(errorMessage: "Watch session deactivated")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            if let vc = self.navigationController?.viewControllers.first as? FaceChooserViewController {
                vc.faceListReloadType = .onlyvisible
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WatchPreviewViewController {
            let vc = segue.destination as? WatchPreviewViewController
            watchPreviewViewController = vc
        }
        if segue.destination is WatchSettingsTableViewController {
            let vc = segue.destination as? WatchSettingsTableViewController
            watchSettingsTableViewController = vc
        }
        
    }
    
    @IBAction func groupChangeAction(sender: UISegmentedControl) {
        
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.currentGroupIndex = sender.selectedSegmentIndex
            watchSettingsTableViewController?.reloadAfterGroupChange()
        }
    }
    
    @IBAction func sendSettingAction() {
        //debugPrint("sendSetting tapped")
        if let validSession = session, let jsonData = SettingsViewController.currentClockSetting.toJSONData() {
            
            validSession.sendMessageData(jsonData, replyHandler: { reply in
                //debugPrint("reply")
                self.showMessage( message: "Watch replied success")
            }, errorHandler: { error in
                //debugPrint("error: \(error)")
                self.showError(errorMessage: error.localizedDescription)
            })
            
            //send background image
            let filename = SettingsViewController.currentClockSetting.clockFaceMaterialName
            let imageURL = UIImage.getImageURL(imageName: filename)
            let fileManager = FileManager.default
            // check if the image is stored already
            if fileManager.fileExists(atPath: imageURL.path) {
                self.showMessage( message: "Sending background image")
                validSession.transferFile(imageURL, metadata: ["type":"clockFaceMaterialImage", "filename":filename])
            }
            
        } else {
            self.showError(errorMessage: "No valid watch session")
        }
    }
    
    @objc func onNotificationForSettingsChanged(notification:Notification) {
        debugPrint("onNotificationForSettingsChanged called")
        redrawPreviewClock()
        setUndoRedoButtonStatus()
    }
    
    @objc func onNotificationForGetCameraImage(notification:Notification) {
            CameraHandler.shared.showActionSheet(vc: self)
            CameraHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                let resizedImage = AppUISettings.imageWithImage(image: image, scaledToSize: CGSize.init(width: 312, height: 390))

                // save it to the docs folder with name of the face
                let fileName = SettingsViewController.currentClockSetting.uniqueID + AppUISettings.backgroundFileName
                debugPrint("got an image!" + resizedImage.description + " filename: " + fileName)
                
                _ = resizedImage.save(imageName: fileName) //_ = resizedImage.save(imageName: fileName)
                SettingsViewController.currentClockSetting.clockFaceMaterialName = fileName
                
                NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
                NotificationCenter.default.post(name: WatchSettingsTableViewController.settingsTableSectionReloadNotificationName, object: nil,
                                                userInfo:["settingType":"clockFaceMaterialName"])
            }
    }
    
    @objc func onNotificationForPreviewSwiped(notification:Notification) {
        
        if let userInfo = notification.userInfo as? [String: String] {
            if userInfo["action"] == "prevClock" {
                prevClock()
            }
            if userInfo["action"] == "nextClock" {
                nextClock()
            }
            if userInfo["action"] == "sendSetting" {
                sendSettingAction()
            }
        }
    }
    
    func redrawPreviewClock() {
        //tell preview to reload
        if watchPreviewViewController != nil {
            watchPreviewViewController?.redraw()
            //self.showMessage( message: SettingsViewController.currentClockSetting.title)
        }
    }
    
    func redrawSettingsTableAfterGroupChange() {
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.reloadAfterGroupChange()
        }
    }
    
    func redrawSettingsTable() {
        //tell the settings table to reload
        if watchSettingsTableViewController != nil {
            watchSettingsTableViewController?.selectCurrentSettings(animated: true)
        }
    }
    
    ////////////////
    func setUndoRedoButtonStatus() {
        debugPrint("undoArray count:" + SettingsViewController.undoArray.count.description)
        if SettingsViewController.undoArray.count>0 {
            undoButton.isEnabled = true
        } else {
            undoButton.isEnabled = false
        }
        if SettingsViewController.redoArray.count > 0 {
            redoButton.isEnabled = true
        } else {
            redoButton.isEnabled = false
        }
    }
    
    static func addToUndoStack() {
        undoArray.append(SettingsViewController.currentClockSetting.clone()!)
        redoArray = []
    }
    
    static func clearUndoStack() {
        undoArray = []
        redoArray = []
    }
    
    func clearUndoAndUpdateButtons() {
        SettingsViewController.clearUndoStack()
        setUndoRedoButtonStatus()
    }
    
    @IBAction func redo() {
        guard let lastSettings = SettingsViewController.redoArray.popLast() else { return } //current setting
        SettingsViewController.undoArray.append(SettingsViewController.currentClockSetting)
        
        SettingsViewController.currentClockSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTableAfterGroupChange() //show new title
        setUndoRedoButtonStatus()
    }
    
    @IBAction func undo() {
        guard let lastSettings = SettingsViewController.undoArray.popLast() else { return } //current setting
        SettingsViewController.redoArray.append(SettingsViewController.currentClockSetting)
        
        SettingsViewController.currentClockSetting = lastSettings
        redrawPreviewClock() //show correct clockr
        redrawSettingsTableAfterGroupChange() //show new title
        setUndoRedoButtonStatus()
    }
    /////////////////
    
    @IBAction func cloneClockSettings() {
        //add a new item into the shared settings
        let oldTitle = SettingsViewController.currentClockSetting.title
        let newClockSetting = SettingsViewController.currentClockSetting.clone(keepUniqueID: false)!
        newClockSetting.title = oldTitle + " copy"
        UserClockSetting.sharedClockSettings.insert(newClockSetting, at: currentClockIndex)
        UserClockSetting.saveToFile()
        
        SettingsViewController.currentClockSetting = newClockSetting
        redrawPreviewClock() //show correct clock
        redrawSettingsTableAfterGroupChange() //show new title
        clearUndoAndUpdateButtons()
        
        showError(errorMessage: "Face copied")
        
        //tell chooser view to reload its cells
        NotificationCenter.default.post(name: FaceChooserViewController.faceChooserReloadChangeNotificationName, object: nil, userInfo:nil)
    }
    
    @IBAction func nextClock() {
        currentClockIndex = currentClockIndex + 1
        if (UserClockSetting.sharedClockSettings.count <= currentClockIndex) {
            currentClockIndex = 0
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func prevClock() {
        currentClockIndex = currentClockIndex - 1
        if (currentClockIndex<0) {
            currentClockIndex = UserClockSetting.sharedClockSettings.count - 1
        }
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
        clearUndoAndUpdateButtons()
    }
    
    func makeThumb( fileName: String) {
        makeThumb(fileName: fileName, cornerCrop: false)
    }
    
    func makeThumb( fileName: String, cornerCrop: Bool ) {
        //make thumbnail
        if let watchVC = watchPreviewViewController {
            
            if watchVC.makeThumb( imageName: fileName, cornerCrop: cornerCrop ) {
                //self.showMessage( message: "Screenshot successful.")
            } else {
                self.showError(errorMessage: "Problem creating screenshot.")
            }
            
        }
    }
    
    @IBAction func shareAll() {
        makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
        if let newImage = UIImage.getImageFor(imageName: SettingsViewController.currentClockSetting.uniqueID) {
            let myWebsite = NSURL(string:"https://github.com/orff/AppleWatchFaces")!
            
            let text = "Watch face \"" + SettingsViewController.currentClockSetting.title + "\" I created using " + myWebsite.absoluteString!
            let shareAll = [newImage, text] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveClock() {
        //just save this clock
        UserClockSetting.sharedClockSettings[currentClockIndex] = SettingsViewController.currentClockSetting
        UserClockSetting.saveToFile() //remove this to reset to defaults each time app loads
        self.showMessage( message: SettingsViewController.currentClockSetting.title + " saved.")
        
        //makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
    }
    
    @IBAction func revertClock() {
        //just revert this clock
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTableAfterGroupChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (self.isMovingFromParent) {
            // moving back, if anything has changed, lets save
            if SettingsViewController.undoArray.count>0 {
                saveClock()
                _ = UIImage.delete(imageName: SettingsViewController.currentClockSetting.uniqueID)
            }
        }
        
        //TODO: probably not needed
        //force clean up memory
        if let scene = watchPreviewViewController?.skView.scene as? SKWatchScene {
            scene.cleanup()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get current selected clock
        redrawSettingsTableAfterGroupChange()
        redrawPreviewClock()
        
        setUndoRedoButtonStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsViewController.clearUndoStack()
        
        //style the section segment
        // Add lines below selectedSegmentIndex
        groupSegmentControl.backgroundColor = .clear
        groupSegmentControl.tintColor = .clear
        
        // Add lines below the segmented control's tintColor
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.white
            ], for: .normal)
        
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.init(hexString: AppUISettings.settingHighlightColor)
            ], for: .selected)
        
        SettingsViewController.currentClockSetting = UserClockSetting.sharedClockSettings[currentClockIndex].clone()!
        
         NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForPreviewSwiped(notification:)), name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSettingsChanged(notification:)), name: SettingsViewController.settingsChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForGetCameraImage(notification:)), name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil)
    }
    
}

