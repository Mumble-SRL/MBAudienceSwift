//
//  MBAudience.swift
//  MBAudience
//
//  Created by Lorenzo Oliveto on 22/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift

class MBAudience: NSObject, MBPluginProtocol {
    override init() {
        MBAudienceManager.shared.incrementSession()
        MBAudienceManager.shared.updateMetadata()
    }
    
    public static func setTag(withKey key: String, value: String) {
        MBAudienceManager.shared.setTag(key: key, value: value)
    }
        
    public static func removeTag(withKey key: String) {
        MBAudienceManager.shared.removeTag(key: key)
    }
    
    public static func setCustomId(_ customId: String) {
        MBAudienceManager.shared.setCustomId(customId)
    }
    
    public static func removeCustomId() {
        MBAudienceManager.shared.setCustomId(nil)
    }
    
    public static func getCustomId() -> String? {
        return MBAudienceManager.shared.getCustomId()
    }

    public static func startLocationUpdates() {
        MBAudienceManager.shared.startLocationUpdates()
    }
    
    public static func stopLocationUpdates() {
        MBAudienceManager.shared.stopLocationUpdates()
    }
    
    public static func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        MBAudienceManager.shared.updateMetadata()
    }
    
    public static func didFailToRegisterForRemoteNotifications(withError error: Error) {
        MBAudienceManager.shared.updateMetadata()
    }

}
