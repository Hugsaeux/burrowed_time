//
//  NewGroupUIViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class NewGroupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    var groupList:GroupList!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveNewGroup") {
            let newGroup: Group = Group(groupName: groupNameTextField.text!)
        
            let api:API = API()
            let locationArray:NSArray = ["0"]
            let groupID:String = api.create_group(groupname: newGroup.getGroupName(), locs: locationArray)
            newGroup.setIdentifier(id: groupID)
        
            groupList.addGroup(group: newGroup)
            groupList.saveGroupListToPhone()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupNameTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
