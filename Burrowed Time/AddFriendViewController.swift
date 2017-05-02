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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "contactListTableSegue") {
            table = segue.destination as! AddressBookTableViewController
            table.groupList = groupList
            table.currentGroup = currentGroup
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
