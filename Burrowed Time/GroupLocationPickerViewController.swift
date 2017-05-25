//
//  GroupLocationPickerViewController.swift
//  Burrowed Time
//
//  Created by Katy on 4/11/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class GroupLocationPickerViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    
    var groupName: String!
    var groupList: GroupList!
    var pageID: String! = ""
    
    var alertController:UIAlertController = UIAlertController(title: "Limit exceeded", message: "Only up to 7 locations can be assigned to each group.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    let nc = NotificationCenter.default
    
    func alertLocationsExceeded(note:Notification) {
        self.present(self.alertController, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        titleTextField.text = groupName
        
        self.alertController.addAction(OKAction)
        nc.addObserver(forName:Notification.Name(rawValue:"GroupLocsExceeded"),
                       object:nil, queue:nil,
                       using:self.alertLocationsExceeded)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLocationCells") {
            let groupLocationTableView:GroupLocationPickerTableViewController! = segue.destination as! GroupLocationPickerTableViewController
            groupLocationTableView.groupList = groupList
            groupLocationTableView.currentGroup = groupName
            groupLocationTableView.pageID = pageID
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if((titleTextField.text?.isEmpty)! || titleTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) == ""){
            self.alertController.title = "Invalid Name"
            self.alertController.message = "Groups cannot have a blank name."
            self.present(self.alertController, animated: true, completion:nil)
            return false
        }
        
        let api:API = API()
        var groupid:String = ""
        for group in groupList.groups {
            if (group.getGroupName() == groupName){
                groupid = group.getIdentifier()
            }
        }
        api.change_group_name(groupid: groupid, groupname: titleTextField.text!)
        
        print(groupid)
        
        textField.resignFirstResponder()
        return false
    }

}
