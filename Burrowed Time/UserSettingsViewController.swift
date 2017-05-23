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
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveUserSettings") {
            print("here")
        
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
        }
    }

    func editingChanged(_ textField: UITextField) {
        
        guard
            let place = usernameTextField.text, !place.isEmpty
            else {
                saveButton.isEnabled = false
                return
        }
        saveButton.isEnabled = true
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
//        usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
//        saveButton.isEnabled = false
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
