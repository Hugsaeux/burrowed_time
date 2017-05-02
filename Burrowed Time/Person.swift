//
//  Person.swift
//  Burrowed Time
//
//  Created by Katy on 1/26/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
//  Class for creation of a person.
//

import Foundation

class Person {
    
    let name:String
    var phoneNumber:String
    var location:String = "Traveling"
    
    init(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
    
    func getName() -> String{
        return self.name
    }
    
    func getPhoneNumber() -> String{
        return self.phoneNumber
    }
    
}
