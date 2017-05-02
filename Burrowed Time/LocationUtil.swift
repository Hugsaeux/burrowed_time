//
//  LocationUtil.swift
//  Burrowed Time
//
//  Created by Anna Gottardi on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

class LocationUtil: NSObject, CLLocationManagerDelegate {
    var manager: CLLocationManager!
    
    override init() {
        super.init()
        manager = CLLocationManager()
        manager.delegate = self
        
        NSLog("initializing location util")
        
        // Request location authorization from user if not already given
        if CLLocationManager.authorizationStatus() == .notDetermined {
            NSLog("requesting authorization")
            manager.requestAlwaysAuthorization()
        }
        /*
        // Clear regions from previous launches
        for region in manager.monitoredRegions {
            NSLog("clearing regions from previous launches")
            manager.stopMonitoring(for: region)
        }
         */
        
        //request location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // When the device exits a region
        // Log which region has been exited
        NSLog("Exited \(region.identifier)")
        
        let api:API = API()
        
        // Retrieve the information associated with that region
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        
        let info:NSArray = storedRegionLookup.regionLookup.object(forKey: region.identifier) as! NSArray
        if (info.count > 0) {
            NSLog("Retrieved info was: \(info).")
            
            // Notify database that user is traveling
            api.exit_location(loc_num: region.identifier)
        } else {
            print("Region was not in RegionLookup.")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // When the device enters a new region
        // Log which region has been entered
        NSLog("Entered \(region.identifier)")
        
        let api:API = API()
        
        // Retrieve the information associated with that region
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        
        let info:NSArray = storedRegionLookup.regionLookup.object(forKey: region.identifier) as! NSArray
        
        if (info.count > 0) {
            NSLog("Retrieved info was: \(info).")
            
            // Notify database which region user has entered
            api.enter_location(loc_num: region.identifier)
        } else {
            print("Region was not in RegionLookup.")
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations[0].coordinate)
//    }
}
