//
//  AddressBookTableViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/23/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import Contacts

class AddressBookTableViewController: UITableViewController {
    var cellData:[CNContact]!
    var groupList:GroupList!
    var currentGroup:String!
    var currentIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (cellData != nil) {
            return cellData.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressScreenGroupCell", for: indexPath) as! AddressBookTableViewCell
        
        cell.cellTitle.text = "\(cellData[indexPath.row].givenName) \(cellData[indexPath.row].familyName)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get mobile number
        var phoneNumber:String = ""
        
        for num in cellData[indexPath.row].phoneNumbers {
            let numVal = num.value
            if num.label == CNLabelPhoneNumberMobile {
                phoneNumber = numVal.stringValue
                break;
            }
        }
        
        if (phoneNumber == "") {
            phoneNumber = "232"
        }
        
        phoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = phoneNumber.characters.count;
        
        if (length != 11) {
            phoneNumber = "1\(phoneNumber)"
        }
        
        let newPerson:Person = Person(name: "\(cellData[indexPath.row].givenName) \(cellData[indexPath.row].familyName)", phoneNumber: phoneNumber)
        
        groupList.addPersonToGroup(groupName: currentGroup, newPerson: newPerson)
        groupList.saveGroupListToPhone()
        currentIndex = groupList.getIndexOfGroup(groupName: currentGroup)
        
        let api:API = API()
        api.invite_to_group(groupid: groupList.groups[groupList.getIndexOfGroup(groupName: currentGroup)].getIdentifier(), phonenumber: phoneNumber)
        
        self.performSegue(withIdentifier: "saveFriendUnwindSegue", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "saveFriendUnwindSegue") {
            let root:RootViewController! = segue.destination as! RootViewController
            root.currentIndex = currentIndex
        }
    }
}
