//
//  RegionLookup.swift
//  Burrowed Time
//
//  Created by Anna Gottardi on 2/8/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
import UIKit

class RegionLookup: NSObject {
    
    // Dictionary mapping region.identifier to matching RegionInfo
    var regionLookup:NSMutableDictionary
    
    let key:String = "RegionLookup"
    
    override init() {
        self.regionLookup = NSMutableDictionary()
    }
    
    init(regionLookup: NSMutableDictionary) {
        self.regionLookup = regionLookup
    }
    
    func saveRegionLookupToPhone() {
        let archiver = NSKeyedArchiver.archivedData(withRootObject: regionLookup)
        UserDefaults.standard.set(archiver, forKey: key)
        NSLog("\(regionLookup)")
    }
    
    func loadRegionLookupFromPhone() {
        // Check if data exists
        guard let data = UserDefaults.standard.object(forKey: key) else {
            NSLog("loadRegionLookupFromPhone data does not exist")
            return
        }
        
        // Check if retrieved data has correct type
        guard let retrievedData = data as? Data else {
            NSLog("loadRegionLookupFromPhone data has incorrect type")
            return
        }
        
        // Unarchive data
        let unarchivedObject:NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: retrievedData) as! NSMutableDictionary
        self.regionLookup = unarchivedObject
        
    }
}
