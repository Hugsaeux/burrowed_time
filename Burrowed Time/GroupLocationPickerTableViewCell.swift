//
//  GroupLocationPickerTableViewCell.swift
//  Burrowed Time
//
//  Created by Katy on 4/11/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class GroupLocationPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    var groupList:GroupList!
    var currentGroup:String!
    var cellIndex:Int!
    
    @IBAction func switchEvent(_ sender: Any) {
        if (!groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].checkLocation(location: locationLabel.text!)) {
            let location:Location = Location(name: locationLabel.text!, locationID: cellIndex)
            groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].addLocation(location: location)
        }
        else {
            groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].removeLocation(location: locationLabel.text!)
        }
        
        //let locations:NSArray = groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations as NSArray
        var locations = [Int]()
        for location in groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].locations {
            locations.append(location.locationID)
        }
        
        let api:API = API()
        api.change_group_locations(groupid: groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier(), locs: locations as NSArray)
        print(groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier())
        print(locations)
        
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
