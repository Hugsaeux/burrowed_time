//
//  DataViewController.swift
//  Burrowed Time
//
//  Created by Katy on 1/18/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

func refreshGroupInfo(group:Group){
    let api:API = API()
    // pull all the members in the group
    let groupMembers:NSDictionary = api.get_group_members(groupid: group.identifier)
    let locations:NSDictionary = api.get_location(userid: "", groupid: group.identifier)
    
    for (key, value) in groupMembers {
        // pull member location
        let location = locations[key as! String] as! String
        
        if (group.checkMemberName(name: value as! String)) {
            let newPerson:Person = Person(name: value as! String, phoneNumber: "232")
            
            // pull new members locations
            
            //self.api.get_location(userid: key as! String, groupid: group.getIdentifier())
            newPerson.location = location
            group.addMember(person: newPerson)
        }
        else {
            //let location = self.api.get_location(userid: key as! String, groupid: group.getIdentifier())
            
            for member in group.members {
                if (member.getName() == value as! String) {
                    member.location = location
                }
            }
        }
    }
    
}

class DataViewController: UIViewController {

    @IBOutlet weak var debuggerLabel: UILabel!
    @IBOutlet weak var editingDoneButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var homeArrow: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var settingsPopUp: UIView!
    @IBOutlet weak var topBarSwitch: UISwitch!
    @IBOutlet weak var homeTable: UIView!
    
    var pageTitle: String = ""
    var currentPage: Int = 0
    var numberOfPages: Int = 1
    var table:HomeTableViewController!
    var groupList:GroupList = GroupList()
    var passedData:String = ""
    var editingMode:Bool = false
    var api:API = API()
    var dataViewController:DataViewController!

    
    
    
    @IBAction func settingsButtonClick(_ sender: Any) {
        settingsPopUp.isHidden = false
    }
    
    @IBAction func invisibilityButtonClick(_ sender: Any) {
        if (self.currentPage == 0) {
            for group in self.groupList.groups {
                group.setVisibility(value: self.topBarSwitch.isOn.description)
                if (self.topBarSwitch.isOn) {
                    DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                        self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 0)
                        self.groupList.saveGroupListToPhone()
                    }
                }
                else {
                   DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                        self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 1)
                        self.groupList.saveGroupListToPhone()
                   }
                }
            }
        }
        else {
            for group in self.groupList.groups {
                if (group.getGroupName() == self.pageTitle) {
                    group.setVisibility(value: self.topBarSwitch.isOn.description)
                    if (self.topBarSwitch.isOn) {
                            DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                                self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 0)
                                self.groupList.saveGroupListToPhone()
                            }
                    }
                    else {
                      DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                            self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 1)
                            self.groupList.saveGroupListToPhone()
                      }
                    }
                }
            }
        }
    
        self.table.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // pull from server
        
        
        if (self.currentPage != 0) {
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                for group in self.groupList.groups {
                    refreshGroupInfo(group: group)
                }
                
                self.groupList.saveGroupListToPhone()
                print("refreshing tables")
                self.table.tableView.reloadData()
            }
        }
            
        else {
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
                _ = userID.loadUserIDFromPhone()
                
                let groups:NSDictionary = self.api.get_user_groups(userid: userID.IDnum)
                
                for (key, value) in groups {
                    if (self.groupList.checkGroupName(name: value as! String)) {
                        let newGroup:Group = Group(groupName: value as! String)
                        newGroup.setIdentifier(id: key as! String)
                        self.groupList.addGroup(group: newGroup)
                    }
                }
                
                self.groupList.saveGroupListToPhone()
            }
        }
        
        let debugger = UserDefaults.standard.object(forKey: "mapdebugger") as! String
        if (debugger == "d") {
            debuggerLabel.text = "Waiting for location"
        }
        else {
            debuggerLabel.text = debugger;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaults.standard.setValue(currentPage, forKey: "homePageIndex")

        groupList = GroupList()
        groupList.loadGroupListFromPhone()
        if (groupList.groups.count == 0) {
            currentPage = 0;
        }
        
        if (groupList.groups.count != 0) {
            self.table.cellData = groupList
            self.table.tableView.reloadData()
        }
        
        self.dataLabel!.text = pageTitle
        self.pageControl!.numberOfPages = numberOfPages
        self.pageControl!.currentPage = currentPage
        if (currentPage == 0) {
            homeArrow.isHidden = true
        }
        else {
            homeArrow.isHidden = false
        }
        if (editingMode && currentPage == 0) {
            self.topBarSwitch.isHidden = true
            self.editingDoneButton.isHidden = false
        }
        else {
            self.editingDoneButton.isHidden = true
        }
        
        if (currentPage == 0) {
            self.dataLabel!.text = "Burrowed Time"
            self.dataLabel!.font = UIFont(name:"GillSans-SemiBold", size: 28.0)
            self.dataLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8784313725, blue: 0.8078431373, alpha: 1)
        }
        else {
            self.dataLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8784313725, blue: 0.8078431373, alpha: 1)
        }
        
        if (currentPage == 0) {
            for group in groupList.groups {
                if (group.visibility == true) {
                    topBarSwitch.isOn = true
                    break
                }
                
                topBarSwitch.isOn = false
            }
        }
        else {
            for group in groupList.groups {
                if (group.getGroupName() == pageTitle) {
                    topBarSwitch.isOn = group.visibility
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homePageSegue") {
            self.table = segue.destination as! HomeTableViewController
            self.table.cellData = groupList
            self.table.index = currentPage
            self.table.dataViewController = self
            self.table.tableView.reloadData()
            if (editingMode && currentPage == 0) {
                table.setEditing(true, animated: true)
            }
        }
        else if (segue.identifier == "settingsSegue") {
            let settings: SettingsPopUpViewController = segue.destination as! SettingsPopUpViewController
            settings.currentPage = currentPage
            settings.groupList = groupList
            settings.pageTitle = pageTitle
        }
    }
}

