//
//  SettingsPopUpViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/21/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class SettingsPopUpViewController: UIViewController {
    @IBOutlet weak var addButton: UILabel!
    @IBOutlet weak var removeButton: UILabel!
    @IBOutlet weak var accountSettingsButton: UILabel!
    @IBOutlet weak var mapSettingsButton: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var removeButtonLabel: UILabel!
    @IBOutlet weak var editLocationsButton: UILabel!
    @IBOutlet weak var checkInvitesButton: UILabel!
    
    var currentPage: Int = 0
    var groupList: GroupList!
    var pageTitle: String!
    var pageID: String = ""
    var dataViewController:DataViewController!

    
    @IBAction func addClick(gestureRecognizer: UIGestureRecognizer) {
        if (currentPage == 0) {
            let addPage:NewGroupViewController! = self.storyboard?.instantiateViewController(withIdentifier: "AddGroupPage") as! NewGroupViewController
            addPage.groupList = groupList
            self.present(addPage, animated: true, completion: nil)
        }
        else {
            let addFriend:AddFriendViewController! = self.storyboard?.instantiateViewController(withIdentifier: "AddFriendPage") as! AddFriendViewController
            addFriend.groupList = groupList
            addFriend.currentGroup = pageTitle
            addFriend.pageID = pageID
            self.present(addFriend, animated: true, completion: nil)
        }
    }
    
    @IBAction func accountSettingsClick(gestureRecognizer: UIGestureRecognizer) {
        let userSettingsPage:UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "UserSettingsPage")
        self.present(userSettingsPage, animated: true, completion: nil)
    }
    
    @IBAction func mapSettingsClick(gestureRecognizer: UIGestureRecognizer) {
        let mapSettingsPage:UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "MapTablePage")
        self.present(mapSettingsPage, animated: true, completion: nil)
    }
    
    @IBAction func removeClick(gestureRecognizer: UIGestureRecognizer) {
        if (currentPage == 0) {
            //dataViewController.topBarSwitch.isHidden = true
            self.performSegue(withIdentifier: "removeGroupUnwindSegue", sender: self)
            
        }
        else {
            let groupLocationPicker:GroupLocationPickerViewController! = self.storyboard?.instantiateViewController(withIdentifier: "GroupLocationPicker") as! GroupLocationPickerViewController
            groupLocationPicker.groupName = pageTitle
            groupLocationPicker.groupList = groupList
            groupLocationPicker.pageID = pageID
            self.present(groupLocationPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func checkInvitesClick(gestureRecognizer: UIGestureRecognizer) {
        let invitesSettingsPage:UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "GroupInvitePage")
        self.present(invitesSettingsPage, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentPage != 0) {
            addButton.text = "  Invite To Group"
            removeButton.text = "  Set Group Locations"

        }
        else {
            addButton.text = "  Create Group"
            removeButton.isHidden = false
            removeButton.text = "  Leave Group"
        }
        
        let addButtonTap = UITapGestureRecognizer(target: self, action: #selector(SettingsPopUpViewController.addClick))
        addButton.isUserInteractionEnabled = true
        addButton.addGestureRecognizer(addButtonTap)
        
        let removeButtonTap = UITapGestureRecognizer(target: self, action: #selector(SettingsPopUpViewController.removeClick))
        removeButton.isUserInteractionEnabled = true
        removeButton.addGestureRecognizer(removeButtonTap)
        
        let accountSettingsTap = UITapGestureRecognizer(target: self, action: #selector(SettingsPopUpViewController.accountSettingsClick))
        accountSettingsButton.isUserInteractionEnabled = true
        accountSettingsButton.addGestureRecognizer(accountSettingsTap)
        
        let mapSettingsTap = UITapGestureRecognizer(target: self, action: #selector(SettingsPopUpViewController.mapSettingsClick))
        mapSettingsButton.isUserInteractionEnabled = true
        mapSettingsButton.addGestureRecognizer(mapSettingsTap)
        
        let checkInvitesTap = UITapGestureRecognizer(target: self, action: #selector(SettingsPopUpViewController.checkInvitesClick))
        checkInvitesButton.isUserInteractionEnabled = true
        checkInvitesButton.addGestureRecognizer(checkInvitesTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "homeTableCellClick") {
            let root:RootViewController! = segue.destination as! RootViewController
            root.currentIndex = currentPage
        }
    }
}
