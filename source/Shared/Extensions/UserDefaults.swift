//
//  UserDefaults.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/23/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import Foundation

struct Defaults {
    
    static let (showAdvancedOptionsKey, advancedOptionPathRenderingKey) = ("show-advanced-features", "feature-pathRendering")
    
    struct Model {
        var showAdvancedOptionsKey: Bool?
        var advancedOptionPathRenderingKey: Bool?
    }
    
    static func saveAdvancedOption(showAdvanced: Bool) {
        debugPrint("saving showAdvancedOptionsKey: " + showAdvanced.description)
        UserDefaults.standard.set(showAdvanced, forKey: showAdvancedOptionsKey)
    }
    
    static func saveAdvancedOptionPathRendering(advancedOptionPathRendering: Bool) {
        debugPrint("saving advancedOptionPathRenderingKey: " + advancedOptionPathRendering.description)
        UserDefaults.standard.set(advancedOptionPathRendering, forKey: advancedOptionPathRenderingKey)
    }

    static func getOptions() -> Model {
        let showAdvanced = UserDefaults.standard.bool(forKey: showAdvancedOptionsKey)
        let advancedOptionPathRendering = UserDefaults.standard.bool(forKey: advancedOptionPathRenderingKey)
        
        return Model.init(showAdvancedOptionsKey: showAdvanced, advancedOptionPathRenderingKey: advancedOptionPathRendering)
    }
    
    static func clearUserData(){
        UserDefaults.standard.removeObject(forKey: showAdvancedOptionsKey)
        UserDefaults.standard.removeObject(forKey: advancedOptionPathRenderingKey)
    }
}
