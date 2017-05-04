//
//  LocationPickerTableViewCell.swift
//  Burrowed Time
//
//  Created by Katy on 4/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class LocationPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    var groupList:GroupList!
    var cellGroupIndex:Int!
    var cellLocation:String!
    var cellIndex:Int!
    
    @IBAction func switchChanged(_ sender: Any) {
        if (groupList.groups[cellGroupIndex].locations.count < 7) {
            if (!groupList.groups[cellGroupIndex].checkLocation(location: cellLocation)) {
                let location:Location = Location(name: cellLocation, locationID: cellIndex)
                groupList.groups[cellGroupIndex].addLocation(location: location)
            }
            else {
                groupList.groups[cellGroupIndex].removeLocation(location: cellLocation)
            }
        }
        else if (groupList.groups[cellGroupIndex].locations.count == 7) {
            if (trackingSwitch.isOn == false) {
                groupList.groups[cellGroupIndex].removeLocation(location: cellLocation)
            }
            else {
                trackingSwitch.setOn(false, animated: true)
            }
        }
        
        var locations = [Int]()
        
        // need identifier from location util
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        for region in locationUtil!.manager.monitoredRegions {
            for location in groupList.groups[cellGroupIndex].locations {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                let title = String(describing: regionInfo[TITLE])
                
                if (title == location.name) {
                    locations.append(Int(regionIdx)!)
                    location.locationID = Int(regionIdx)!
                }
            }
        }
        
        let api:API = API()
        api.change_group_locations(groupid: groupList.groups[cellGroupIndex].getIdentifier(), locs: locations as NSArray)
        
        
        groupList.saveGroupListToPhone()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
