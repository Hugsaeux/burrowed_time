//
//  HomeTableViewCell.swift
//  Burrowed Time
//
//  Created by Katy on 1/22/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellLocation: UILabel!
    @IBOutlet weak var invisibilitySwitch: UISwitch!
    
    var groupList:GroupList! = nil
    var dataViewController:DataViewController! = nil
    var api:API = API();
    
    @IBAction func switchEvent(_ sender: AnyObject) {
        groupList.groups[groupList.getIndexOfGroup(groupName: cellTitle.text!)].visibility = invisibilitySwitch.isOn
        groupList.saveGroupListToPhone()
        
        if (invisibilitySwitch.isOn) {
          //  DispatchQueue.main.async {
                self.api.set_invisible(groupid: self.groupList.groups[self.groupList.getIndexOfGroup(groupName: self.cellTitle.text!)].getIdentifier(), is_invisible: 0)
           // }
        }
        else {
           // DispatchQueue.main.async {
                self.api.set_invisible(groupid: self.groupList.groups[self.groupList.getIndexOfGroup(groupName: self.cellTitle.text!)].getIdentifier(), is_invisible: 1)
          //  }
        }
        
        for group in groupList.groups {
            if (group.visibility == true) {
                dataViewController.topBarSwitch.isOn = true
                break
            }
            
            dataViewController.topBarSwitch.isOn = false
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

//    override func setEditing(_ editing: Bool, animated: Bool) {
//        if (editing){
//            //deleteButton.enabled = YES;
//        }
//    }
    
}
