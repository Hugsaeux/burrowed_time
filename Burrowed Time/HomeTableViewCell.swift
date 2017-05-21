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
    @IBOutlet weak var eyeOpenIcon: UIImageView!
    @IBOutlet weak var eyeClosedIcon: UIImageView!
    
    var groupList:GroupList! = nil
    var dataViewController:DataViewController! = nil
    var api:API = API();
    var cellID:String!
    
    @IBAction func switchEvent(_ sender: AnyObject) {
        groupList.groups[groupList.getIndexOfGroup(groupID: cellID)].visibility = invisibilitySwitch.isOn
        groupList.saveGroupListToPhone()
        
        if (invisibilitySwitch.isOn) {
            self.eyeClosedIcon.isHidden = true
          //  DispatchQueue.main.async {
                self.api.set_invisible(groupid: self.groupList.groups[self.groupList.getIndexOfGroup(groupID: cellID)].getIdentifier(), is_invisible: 0)
           // }
            self.eyeOpenIcon.isHidden = false
        }
        else {
            self.eyeOpenIcon.isHidden = true
           // DispatchQueue.main.async {
                self.api.set_invisible(groupid: self.groupList.groups[self.groupList.getIndexOfGroup(groupID: cellID)].getIdentifier(), is_invisible: 1)
          //  }
            self.eyeClosedIcon.isHidden = false
        }
        
        for group in groupList.groups {
            if (group.visibility == true) {
                dataViewController.topBarSwitch.isOn = true
                dataViewController.closedEyeIcon.isHidden = true
                dataViewController.openEyeIcon.isHidden = false
                break
            }
            
            dataViewController.topBarSwitch.isOn = false
            dataViewController.closedEyeIcon.isHidden = false
            dataViewController.openEyeIcon.isHidden = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (invisibilitySwitch.isOn) {
            self.eyeClosedIcon.isHidden = true
            self.eyeOpenIcon.isHidden = false
        }
        else {
            self.eyeOpenIcon.isHidden = true
            self.eyeClosedIcon.isHidden = false
        }
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
