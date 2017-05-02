//
//  RegionIdx.swift
//  Burrowed Time
//
//  Created by Anna Gottardi on 2/8/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
import UIKit

class RegionIdx: NSObject {
    
    var regionIdx:NSString
    let key:String = "RegionIdx"
    
    override init() {
        self.regionIdx = "0"
    }
    
    //  save the regionIdx to userDefaults on the phone
    func saveRegionIdxToPhone(){
        UserDefaults.standard.setValue(self.regionIdx, forKey: key)
        NSLog("\(UserDefaults.standard.value(forKey: key)!)")
    }
    
    
    //  load the regionIdx from the phone
    func loadRegionIdxFromPhone() {
        let loadedRegionIdx:NSString = UserDefaults.standard.object(forKey: key) as! NSString
        self.regionIdx = loadedRegionIdx
    }
    
    
    // increment regionIdx
    func incrementIdx() {
        var intIdx = Int(self.regionIdx as String)!
        intIdx = intIdx + 1
        self.regionIdx = String(describing: intIdx) as NSString
        print("RegionIdx: \(intIdx)")
    }
    
    // decrement regionIdx
    func decrementIdx() {
        var intIdx = Int(self.regionIdx as String)!
        intIdx = intIdx - 1
        self.regionIdx = String(describing: intIdx) as NSString
    }
}
