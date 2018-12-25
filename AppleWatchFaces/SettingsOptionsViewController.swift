//
//  SettingsOptionsViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/23/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class SettingsOptionsViewController: UIViewController {

    @IBOutlet var optionShowAdvanced: UISwitch!
    @IBOutlet var optionShowPathRenderingOptions: UISwitch!
    
    @IBAction func showAdvancedOptionsSwitchDidChange( sender: UISwitch ) {
        Defaults.saveAdvancedOption(showAdvanced: sender.isOn)
    }
    
    @IBAction func showOptionPathRenderingSwitchDidChange( sender: UISwitch ) {
        Defaults.saveAdvancedOptionPathRendering(advancedOptionPathRendering: sender.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let options = Defaults.getOptions()
        
        if let showAdvanced = options.showAdvancedOptionsKey {
            optionShowAdvanced.isOn = showAdvanced
        }
        if let showOptionPathRendering = options.advancedOptionPathRenderingKey {
            optionShowPathRenderingOptions.isOn = showOptionPathRendering
        }

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
