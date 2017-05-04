//
//  Invitation.swift
//  Burrowed Time
//
//  Created by Hugsaeux on 5/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import Foundation

class Invitation {
    
    let id:String
    let inviter:String
    let group:String
    
    init(id: String, inviter: String, group: String) {
        self.id = id
        self.inviter = inviter
        self.group = group
    }
    
    func getId() -> String {
        return self.id
    }
    
    func getInviter() -> String {
        return self.inviter
    }
    
    func getGroup() -> String {
        return self.group
    }
    
}
