//
//  LoginScreenViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/22/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import Contacts

class LoginScreenViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (userNameTextField.text != "" && phoneNumberTextField.text != "") {
            let api:API = API()
            
            let id:String = api.add_user(username: userNameTextField.text!, phonenumber: phoneNumberTextField.text!)
            
            let userID:UserID = UserID(IDnum: id, userName: userNameTextField.text!, phoneNumber: phoneNumberTextField.text!)
            userID.saveUserIDToPhone()
        }
    }
}
