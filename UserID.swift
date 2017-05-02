//
//  UserID.swift
//  Burrowed Time
//
//  Created by Anna Gottardi on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import Foundation

class UserID {
    
    var IDnum:String = ""
    var username:String = ""
    var phoneNumber:String = ""
    
    let key:String = "UserID"

    init(IDnum:String, userName:String, phoneNumber:String) {
        self.IDnum = IDnum
        self.username = userName
        self.phoneNumber = phoneNumber
    }
    
    //  save the UserID to userDefaults on the phone
    func saveUserIDToPhone(){
        let saveString = "\(IDnum);\(username);\(phoneNumber)"
        UserDefaults.standard.setValue(saveString, forKey: key)
        print("\(UserDefaults.standard.value(forKey: key)!)")
    }
    
    
    //  load the UserID from the phone
    func loadUserIDFromPhone() -> Bool{
        if (UserDefaults.standard.object(forKey: key) != nil) {
            let loadedUserID:String = UserDefaults.standard.object(forKey: key) as! String
            var splitString = loadedUserID.characters.split(separator: ";").map(String.init)
            self.IDnum = splitString[0]
            self.username = splitString[1]
            self.phoneNumber = splitString[2]
            
            return true
        }
        else {
            return false
        }
    }
    
    
    //  compare the UserID to another UserID
    //  returns true if userIDs are the same and false otherwise
    func compareUserID(userID2: UserID) -> Bool {
        if (self.IDnum == userID2.IDnum) {
            return true
        }
        
        return false
    }
    
    func getUsername() -> String {
        return self.username
    }
    
    func getPhoneNumber() -> String {
        return self.phoneNumber
    }
    
    func getIDnum() -> String {
        return self.IDnum
    }
    
}
