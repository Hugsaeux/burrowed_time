//
//  AddFriendViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import Contacts

class AddFriendViewController: UIViewController {
    @IBOutlet weak var addFriendTextField: UITextField!
    
    var groupList: GroupList!
    var currentGroup: String!
    var cellData:[CNContact]!
    var table:AddressBookTableViewController!
    
    var alertController:UIAlertController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "contactListTableSegue") {
            table = segue.destination as! AddressBookTableViewController
            table.groupList = groupList
            table.currentGroup = currentGroup
        }
    }
    
    @IBAction func addButtonPress(_ sender: Any) {
        let number = Int(addFriendTextField.text!)
        if (number != nil) {
            let api:API = API()
            let result = api.invite_to_group(groupid: groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier(), phonenumber: addFriendTextField.text!)
            
            if (result["Success"] as! Bool){
                self.alertController.title = "Success"
                self.alertController.message = "Invitation Sent"
            }else{
                self.alertController.title = "Invitation Failed"
                self.alertController.message = (result["Message"] as! String)
            }
            
            self.present(self.alertController, animated: true, completion:nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertController = UIAlertController(title: "Default AlertController", message: "A standard alert", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
            print("you have pressed Okay button");
            //Call another alert here
            
            if (self.alertController.title == "Success") {
                self.performSegue(withIdentifier: "saveAddFriend", sender: self)
            }
        }
        
        self.alertController.addAction(OKAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addFriendTextFieldChanged() {
        if (addFriendTextField.text != "") {
            let contacts:CNContactStore = CNContactStore()
            let predicate:NSPredicate = CNContact.predicateForContacts(matchingName: addFriendTextField.text!)
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            cellData = try! contacts.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as [CNKeyDescriptor])
            table.cellData = cellData
            
            self.table.tableView.reloadData()
        }
    }
}
