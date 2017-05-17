//
//  UserSettingsViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let root:RootViewController! = segue.destination as! RootViewController
        //root.passedData = "\(usernameTextField.text!);\(phoneNumberTextField.text!)"
        
        if (usernameTextField.text! != "") {
            let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
            _ = userID.loadUserIDFromPhone()
            
            if (usernameTextField.text != "") {
                userID.username = usernameTextField.text!
            }
            userID.saveUserIDToPhone()
            
            let api:API = API()
            api.update_user_info(username: usernameTextField.text!, userid: userID.getIDnum())
            
            let groupList = GroupList()
            groupList.saveGroupListToPhone()
        }
        
//        if (phoneNumberTextField.text != "") {
//            userID.phoneNumber = phoneNumberTextField.text!
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
        _ = userID.loadUserIDFromPhone()
        
        let username = userID.getUsername()
        //let phoneNumber = userID.getPhoneNumber()
        
        usernameTextField.text = username
        //phoneNumberTextField.placeholder = phoneNumber
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
