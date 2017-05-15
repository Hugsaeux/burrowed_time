//
//  FriendsList.swift
//  Burrowed Time
//
//  Created by Katy on 1/28/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
//  Class for a list of groups, the main datastructure for the program
//  Contains a list of groups, which each contain a list of persons

import Foundation

class GroupList {
    
    var groups = [Group]()
    let key:String = "GroupList"
    
    init() {
        groups = [Group]()
    }
    
    func dataToJSON() -> String {
        var index = 1;
        var JSONstring:String = "{\"GroupList\":{"
        
        for group in self.groups {
            //JSONstring = "\(JSONstring)\"\(group.getGroupName())\":{\"groupName\":\"\(group.getGroupName())\",\"members\":{"
            JSONstring = "\(JSONstring)\"\(group.getGroupName());\(group.getIdentifier())\":{\"members\":{"
            for person in group.members {
                //JSONstring = "\(JSONstring)\"\(person.getName())\":{\"name\":\"\(person.getName())\",\"phoneNumber\":\"\
                JSONstring = "\(JSONstring)\"\(person.getName())\":{\"phoneNumber\":\"\(person.phoneNumber)\","
                JSONstring = "\(JSONstring)\"location\":\"\(person.location)\""
                if (person.getName() != group.members[group.getSize()-1].getName()) {
                    JSONstring = "\(JSONstring)},"
                }
                else {
                    JSONstring = "\(JSONstring)}"
                }
            }
            JSONstring = "\(JSONstring)},\"visibility\":\"\(group.visibility)\","
            
            JSONstring = "\(JSONstring)\"locations\":{"
            // loop through locations 
            // add locations in based on { Home : false
            var locationIndex = 1;
            for location in group.locations {
                JSONstring = "\(JSONstring)\"\(location.getName())\": \"\(String(location.getLocationID()))\""
                
                if (locationIndex == group.locations.count) {
                    JSONstring = "\(JSONstring)}"
                }
                
                else {
                    JSONstring = "\(JSONstring),"
                }
                
                locationIndex+=1;
            }
            
            if (group.locations.count == 0) {
                JSONstring = "\(JSONstring)}"
            }
            
            JSONstring = "\(JSONstring)}"
            
            if (group.getGroupName() != self.groups[self.groups.count-1].getGroupName()) {
                JSONstring = "\(JSONstring),"
            }
            
//            if (index == self.groups.count) {
//                JSONstring = "\(JSONstring)}"
//            }
//            else {
//                JSONstring = "\(JSONstring)}"
//            }
            
            index+=1
        }
        
        JSONstring = "\(JSONstring)}}"
        //print(JSONstring)
        return JSONstring
    }
    
    //  add group to the list
    func addGroup(group: Group){
        if (checkGroupName(name: group.getGroupName())) {
            self.groups.append(group)
        }
    }
    
    // check if group with same name already exists
    func checkGroupName(name: String) -> Bool {
        for group in groups {
            if (group.getGroupName() == name) {
                return false
            }
        }
        
        return true
    }
    
    //  remove a group from the list
    func removeGroup(groupName: String) {
        var name1:String
        let name2:String = groupName
        
        for i in 0 ..< groups.count {
            name1 = groups[i].getGroupName()
            if (name1 == name2) {
                groups.remove(at: i)
                break;
            }
        }
    }
    
    //  get the size of the GroupList
    func getSize() -> Int {
        return self.groups.count
    }
    
    //  save the GroupList to userDefaults on the phone
    func saveGroupListToPhone(){
        let JSONstring:String = self.dataToJSON()
        UserDefaults.standard.setValue(JSONstring, forKey: key)
    }
    
    //  load the GroupList from the phone
    func loadGroupListFromPhone() {
        if (UserDefaults.standard.object(forKey: key) != nil) {
            let JSONstring:String = UserDefaults.standard.object(forKey: key) as! String
            let data:Data = JSONstring.data(using: .utf8)!
            let json = try? JSONSerialization.jsonObject(with: data) as! [String:Any]
            let groupListString = json?["GroupList"] as! [String:Any]
            
        
            for (groupInfo, _) in groupListString {
                var splitString = groupInfo.characters.split(separator: ";").map(String.init)
                let group:Group = Group(groupName: splitString[0])
                group.setIdentifier(id: splitString[1])
                
                let people = groupListString[groupInfo] as! [String:Any]
                let members = people["members"] as! [String:Any]
                let locations = people["locations"] as! [String:Any]
                group.visibility = people["visibility"] as! String == "true"
                
                for (person, _) in members {
                    let personIndex = members[person] as! [String:Any]
                    let newPerson:Person = Person(name: person, phoneNumber: "232")
                    
                    for (key, value) in personIndex {
                    
                        if (key == "phoneNumber") {
                            newPerson.phoneNumber = value as! String
                        }
                        else if (key == "location") {
                            newPerson.location = value as! String
                        }
                    }
                    
                    group.addMember(person: newPerson)
                }
                
                for (location, locationID) in locations {
                    
                    let newLocation:Location = Location(name: location, locationID: (locationID as! NSString).integerValue)
                    group.addLocation(location: newLocation)
                }
            
                self.addGroup(group: group)
            }
        }
        
        
    }
    
    /*
    func loadGroupListFromAWS() {
     
    }
     */
    
    //  compare the GroupList to another GroupList
    //  may need some updates for edge cases
    func compareGroupList(groupList2: GroupList) -> Bool {
        if (self.getSize() == groupList2.getSize()) {
            for i in 0 ..< groups.count {
                if (self.groups[i].getSize() != groupList2.groups[i].getSize()) {
                    return false
                }
            }
        }
            
        else {
            return false
        }
        
        return true
    }
    
    func addPersonToGroup(groupName: String, newPerson: Person) {
        for group in groups {
            if (group.getGroupName() == groupName) {
                group.addMember(person: newPerson)
            }
        }
    }
    
    func getIndexOfGroup(groupName: String) -> Int {
        var index = 0
        for group in groups {
            if (group.getGroupName() == groupName) {
                return index
            }
            index+=1;
        }
        
        return -1
    }
}
