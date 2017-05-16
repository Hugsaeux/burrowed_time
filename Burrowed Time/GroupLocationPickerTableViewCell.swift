//
//  GroupLocationPickerTableViewCell.swift
//  Burrowed Time
//
//  Created by Katy on 4/11/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import MapKit

class GroupLocationPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    var groupList:GroupList!
    var currentGroup:String!
    var cellIndex:Int!
    
    let nc = NotificationCenter.default
    
    @IBAction func switchEvent(_ sender: Any) {
        if (groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations.count < 7) {
            if (!groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].checkLocation(location: locationLabel.text!)) {
                let location:Location = Location(name: locationLabel.text!, locationID: cellIndex)
                groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].addLocation(location: location)
            }
            else {
                groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].removeLocation(location: locationLabel.text!)
            }
            
            var locations = [Int]()
            let storedRegionLookup = RegionLookup()
            storedRegionLookup.loadRegionLookupFromPhone()
            for region in locationUtil!.manager.monitoredRegions {
                for location in groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations {
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
            api.change_group_locations(groupid: groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier(), locs: locations as NSArray)
            
            groupList.saveGroupListToPhone()
            //updateCurrentLocation()
        }
            
        else if (groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations.count == 7 && locationSwitch.isOn == false) {
            groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].removeLocation(location: locationLabel.text!)
            
            var locations = [Int]()
            let storedRegionLookup = RegionLookup()
            storedRegionLookup.loadRegionLookupFromPhone()
            for region in locationUtil!.manager.monitoredRegions {
                for location in groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations {
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
            api.change_group_locations(groupid: groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier(), locs: locations as NSArray)
            
            groupList.saveGroupListToPhone()
            //updateCurrentLocation()
        }
        else {
            nc.post(name:Notification.Name(rawValue:"GroupLocsExceeded"),
                    object: nil,
                    userInfo: ["message":"Hello there!", "date":Date()])
            locationSwitch.setOn(false, animated: true)
        }
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
