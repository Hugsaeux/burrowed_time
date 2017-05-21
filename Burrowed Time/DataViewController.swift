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
    NSLog("groupMembers: \(groupMembers)")
    NSLog("locations: \(locations)")
    group.members = [];
    
    for (key, value) in groupMembers {
        // pull member location
        let location = locations[key as! String] as! String
        let newPerson:Person = Person(name: value as! String, phoneNumber: "232")
        newPerson.location = location
        group.addMember(person: newPerson)
    }
    
    group.members = group.members.sorted {
        $0.name < $1.name
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
    @IBOutlet weak var closedEyeIcon: UIImageView!
    @IBOutlet weak var openEyeIcon: UIImageView!
    @IBOutlet weak var homeIcon: UIImageView!
    
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
                    closedEyeIcon.isHidden = true
                    DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                        self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 0)
                        self.groupList.saveGroupListToPhone()
                        self.table.refreshData()
                        self.table.tableView.reloadData()
                    }
                    openEyeIcon.isHidden = false
                }
                else {
                    openEyeIcon.isHidden = true
                    DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                        self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 1)
                        self.groupList.saveGroupListToPhone()
                        self.table.refreshData()
                        self.table.tableView.reloadData()
                    }
                    closedEyeIcon.isHidden = false
                }
            }
        }
        else {
            for group in self.groupList.groups {
                if (group.getGroupName() == self.pageTitle) {
                    group.setVisibility(value: self.topBarSwitch.isOn.description)
                    if (self.topBarSwitch.isOn) {
                        closedEyeIcon.isHidden = true
                        DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                            self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 0)
                            self.groupList.saveGroupListToPhone()
                            self.table.refreshData()
                            self.table.tableView.reloadData()
                        }
                        openEyeIcon.isHidden = false
                    }
                    else {
                        openEyeIcon.isHidden = true
                        DispatchQueue.global(qos: DispatchQoS.background.qosClass).sync {
                            self.api.set_invisible(groupid: group.getIdentifier(), is_invisible: 1)
                            self.groupList.saveGroupListToPhone()
                            self.table.refreshData()
                            self.table.tableView.reloadData()
                        }
                        closedEyeIcon.isHidden = false
                    }
                }
            }
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
            if (currentPage != 0) {
                groupList.groups[currentPage-1].members = groupList.groups[currentPage-1].members.sorted {
                    $0.name < $1.name
                }
            }
            self.table.cellData = groupList
            self.table.tableView.reloadData()
        }
        
        self.dataLabel!.text = pageTitle
        self.dataLabel!.font = UIFont(name:"GillSans-SemiBold", size: 28.0)
        self.dataLabel!.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        self.pageControl!.numberOfPages = numberOfPages
        self.pageControl!.isUserInteractionEnabled = false
        self.pageControl!.currentPage = currentPage
        if (currentPage == 0) {
            homeArrow.isHidden = true
            homeIcon.isHidden = false
        }
        else {
            homeArrow.isHidden = false
            homeIcon.isHidden = true
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
            self.dataLabel!.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.dataLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8784313725, blue: 0.8078431373, alpha: 1)
        }
        else {
            self.dataLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8784313725, blue: 0.8078431373, alpha: 1)
        }
        
        if (currentPage == 0) {
            for group in groupList.groups {
                if (group.visibility == true) {
                    topBarSwitch.isOn = true
                    closedEyeIcon.isHidden = true
                    openEyeIcon.isHidden = false
                    break
                }
                
                topBarSwitch.isOn = false
                closedEyeIcon.isHidden = false
                openEyeIcon.isHidden = true
            }
        }
        else {
            for group in groupList.groups {
                if (group.getGroupName() == pageTitle) {
                    topBarSwitch.isOn = group.visibility
                    closedEyeIcon.isHidden = group.visibility
                    openEyeIcon.isHidden = !group.visibility
                }
            }
        }
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            self.table.refreshData();
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homePageSegue") {
            self.table = segue.destination as! HomeTableViewController
            self.table.index = currentPage
            self.table.dataViewController = self
            self.table.tableView.reloadData()
            if (editingMode && currentPage == 0) {
                table.setEditing(true, animated: true)
            }
            self.table.cellData = groupList
        }
        else if (segue.identifier == "settingsSegue") {
            let settings: SettingsPopUpViewController = segue.destination as! SettingsPopUpViewController
            settings.currentPage = currentPage
            settings.groupList = groupList
            settings.pageTitle = pageTitle
        }
    }
}

