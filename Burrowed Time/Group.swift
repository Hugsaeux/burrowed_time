//
//  Group.swift
//  Burrowed Time
//
//  Created by Katy on 1/26/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
//  Class for a group containing a list of Persons//

import Foundation

class Group {
    
    var groupName:String
    var visibility:Bool
    var members = [Person]()
    var identifier:String!
    var locations = [Location]()
    
    init(groupName: String) {
        self.groupName = groupName
        members = [Person]()
        locations = [Location]()
        visibility = true
    }
    
    func setVisibility(value: String) {
        visibility = value == "true"
    }
    
    func isLocationsEmpty() -> Bool {
        if (locations.count == 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func addLocation(location:Location) {
        locations.append(location)
    }
    
    func removeLocation(location:String) {
        var index = 0;
        for loc in locations {
            if (location == loc.getName()) {
                locations.remove(at: index)
                break
            }
            index+=1
        }
    }
    
    func checkLocation(location:String) -> Bool {
        for loc in locations {
            if (loc.getName() == location) {
                return true
            }
        }
        return false
    }
    
    func getGroupName() -> String{
        return self.groupName
    }
    
    func addMember(person: Person) {
        if (checkMemberName(name: person.getName())) {
            self.members.append(person)
        }
    }
    
    // check if member is already in the group
    func checkMemberName(name: String) -> Bool {
        for person in members {
            if (person.getName() == name) {
                return false
            }
        }
        
        return true
    }
    
    func removeMember(person: Person) {
        var name1:String
        let name2:String = person.getName()
        
        for i in 0 ..< members.count {
            name1 = members[i].getName()
            if (name1 == name2) {
                members.remove(at: i)
            }
        }
    }
    
    func getSize() -> Int {
        return self.members.count
    }
    
    func setIdentifier(id: String) {
        self.identifier = id
    }
    
    func getIdentifier() -> String {
        return self.identifier
    }
}
