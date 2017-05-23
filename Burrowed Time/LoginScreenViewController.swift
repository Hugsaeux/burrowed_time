//
//  LoginScreenViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/22/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import Contacts

class LoginScreenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var phoneNumber = phoneNumberTextField.text!
        if (userNameTextField.text != "" && phoneNumberTextField.text != "") {
            
           
            
            if (phoneNumber.characters.count > 10) {
                
                phoneNumber = String(phoneNumber.characters.suffix(10)) //Strip off country codes
            }
            
            let api:API = API()
            
            let lookUp = api.lookup_user(phonenumber: phoneNumberTextField.text!)
            let userID = lookUp.object(forKey: "userid") as! Int
            
            if (userID != -1) {
                let userID:UserID = UserID(IDnum: userID.description, userName: userNameTextField.text!, phoneNumber: phoneNumber)
                userID.saveUserIDToPhone()
                
                // Update user info to reflect typed-in name
                let api:API = API()
                api.update_user_info(username: userNameTextField.text!, userid: userID.getIDnum())
            }
            else {
                let id:String = api.add_user(username: userNameTextField.text!, phonenumber: phoneNumber)
                
                let userID:UserID = UserID(IDnum: id, userName: userNameTextField.text!, phoneNumber: phoneNumber)
                userID.saveUserIDToPhone()
            }
            
        }
    }
}
