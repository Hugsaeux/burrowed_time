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
            
            for region in locationUtil!.manager.monitoredRegions {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                
                //check if in bounds
                let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
                let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
                let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let ourLocation = locationUtil!.manager.location
                let clLocCoor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = ourLocation?.distance(from: clLocCoor)
                
                if ((distance! as Double) < radius) {
                    api.enter_location(loc_num: regionIdx)
                }
                else {
                    api.exit_location(loc_num: regionIdx)
                }
            }
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
            
            for region in locationUtil!.manager.monitoredRegions {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                
                //check if in bounds
                let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
                let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
                let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let ourLocation = locationUtil!.manager.location
                let clLocCoor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = ourLocation?.distance(from: clLocCoor)
                
                if ((distance! as Double) < radius) {
                    api.enter_location(loc_num: regionIdx)
                }
                else {
                    api.exit_location(loc_num: regionIdx)
                }
            }
        }
        else {
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
