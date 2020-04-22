//
//  MBAudienceManager.swift
//  MBAudience
//
//  Created by Lorenzo Oliveto on 09/04/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit
import MBurgerSwift
import UserNotifications
import CoreLocation

internal class MBAudienceManager: NSObject {
    internal static let shared = MBAudienceManager()
    
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocationCoordinate2D?
    
    func setTag(key: String, value: String) { // TODO: save it in db or file
        var newTags = getTags() ?? []
        if let indexFound = newTags.firstIndex(where: {$0.key == key}) {
            let tag = newTags[indexFound]
            tag.value = value
            newTags[indexFound] = tag
        } else {
            newTags.append(MBTag(key: key, value: value))
        }
        saveNewTags(tags: newTags)
        updateMetadata()
    }
    
    func removeTag(key: String) { // TODO: save it in db or file
        var newTags = getTags() ?? []
        if let indexFound = newTags.firstIndex(where: {$0.key == key}) {
            newTags.remove(at: indexFound)
        }
        saveNewTags(tags: newTags)
        updateMetadata()
    }
    
    private func saveNewTags(tags: [MBTag]) {
        let userDefaults = UserDefaults.standard
        let mappedTags = tags.map({ $0.toDictionary() })
        userDefaults.set(mappedTags, forKey: "com.mumble.mburger.audience.tags")
    }
    
    func getTags() -> [MBTag]? {
        let userDefaults = UserDefaults.standard
        guard let tags = userDefaults.object(forKey: "com.mumble.mburger.audience.tags") as? [[String: String]] else {
            return nil
        }
        return tags.map({MBTag(dictionary: $0)})
    }
    
    func getTagsAsDictionaries() -> [[String: String]]? {
        let userDefaults = UserDefaults.standard
        guard let tags = userDefaults.object(forKey: "com.mumble.mburger.audience.tags") as? [[String: String]] else {
            return nil
        }
        return tags
    }
    
    func setCustomId(_ customId: String?) {
        let userDefaults = UserDefaults.standard
        if let customId = customId {
            userDefaults.set(customId, forKey: "com.mumble.mburger.audience.customId")
        } else {
            userDefaults.removeObject(forKey: "com.mumble.mburger.audience.customId")
        }
        updateMetadata()
    }
    
    func getCustomId() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "com.mumble.mburger.audience.customId") as? String
    }
    
    func startLocationUpdates() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.delegate = self
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopLocationUpdates() {
        if let locationManager = locationManager {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // MARK: - Sessions
    
    func incrementSession() {
        let userDefaults = UserDefaults.standard
        let session = userDefaults.integer(forKey: "com.mumble.mburger.audience.session")
        userDefaults.set(session + 1, forKey: "com.mumble.mburger.audience.session")
        userDefaults.synchronize()
    }
    
    var currentSession: Int {
        return UserDefaults.standard.integer(forKey: "com.mumble.mburger.audience.session")
    }
    
    // MARK: - Api
    
    func updateMetadata() {
        DispatchQueue.global(qos: .utility).async {
            let locale = Locale.preferredLanguages.first
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] settings in
                guard let strongSelf = self else {
                    return
                }
                let pushEnabled = settings.authorizationStatus == .authorized
                
                let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
                let locationEnabled = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
                
                var parameters = [String: AnyHashable]()
                parameters["push_enabled"] = pushEnabled ? "true" : "false"
                parameters["location_enabled"] = locationEnabled ? "true" : "false"
                parameters["locale"] = locale ?? "en_US"
                parameters["app_version"] = version
                parameters["sessions"] = NSNumber(value: strongSelf.currentSession).stringValue
                
                parameters["sessions_time"] = "0" //TODO: implement
                parameters["last_session"] = "0" //TODO: implement
                //TODO: mobile user id
                
                if let customId = strongSelf.getCustomId() {
                    parameters["custom_id"] = customId
                }
                
                if let currentLocation = strongSelf.currentLocation {
                    parameters["latitude"] = currentLocation.latitude.truncate(places: 8)
                    parameters["longitude"] = currentLocation.longitude.truncate(places: 8)
                }
                
                if let tags = strongSelf.getTagsAsDictionaries() {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: tags, options: []) {
                        parameters["tags"] = String(data: jsonData, encoding: .utf8)
                    }
                }
                
                MBApiManager.request(withToken: MBManager.shared.apiToken,
                                     locale: MBManager.shared.localeString,
                                     apiName: "devices",
                                     method: .post,
                                     parameters: parameters,
                                     development: MBManager.shared.development,
                                     success: { _ in
                                        //TODO: call delegate?
                }) { _ in
                    //TODO: call delegate?
                }
            })
        }
    }
    
    func updateLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        var parameters = [String: AnyHashable]()
        parameters["latitude"] = currentLocation.latitude.truncate(places: 8)
        parameters["longitude"] = currentLocation.longitude.truncate(places: 8)
        DispatchQueue.global(qos: .utility).async {
            MBApiManager.request(withToken: MBManager.shared.apiToken,
                                 locale: MBManager.shared.localeString,
                                 apiName: "devices",
                                 method: .post,
                                 parameters: parameters,
                                 development: MBManager.shared.development,
                                 success: { _ in
                                    //TODO: call delegate?
            }) { _ in
                //TODO: call delegate?
            }
        }
    }
}

extension MBAudienceManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            currentLocation = lastLocation.coordinate
            updateLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
