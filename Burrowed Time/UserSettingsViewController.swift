//
//  UserSettingsViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let root:RootViewController! = segue.destination as! RootViewController
        root.passedData = "\(usernameTextField.text!);\(phoneNumberTextField.text!)"
        
        let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
        _ = userID.loadUserIDFromPhone()
        
        if (usernameTextField.text != "") {
            userID.username = usernameTextField.text!
        }
        
        if (phoneNumberTextField.text != "") {
            userID.phoneNumber = phoneNumberTextField.text!
        }
        
        userID.saveUserIDToPhone()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
        _ = userID.loadUserIDFromPhone()
        
        let username = userID.getUsername()
        let phoneNumber = userID.getPhoneNumber()
        
        usernameTextField.placeholder = username
        phoneNumberTextField.placeholder = phoneNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
