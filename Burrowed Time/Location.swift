//
//  location.swift
//  Burrowed Time
//
//  Created by Katy on 4/16/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

class Location {
    
    let name:String
    var locationID:Int
    
    init(name: String, locationID: Int) {
        self.name = name
        self.locationID = locationID
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getLocationID() -> Int {
        return self.locationID
    }
    
    func setLocationID(newID: Int) {
        self.locationID = newID
    }
}
