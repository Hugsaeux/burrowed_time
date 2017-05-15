//
//  API.swift
//  Burrowed Time
//
//  Created by Hugsaeux on 3/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import Foundation
import Alamofire

class API {
    let userID = UserID(IDnum: "", userName: "", phoneNumber: "")
    init(){
        _ = userID.loadUserIDFromPhone()
        //print("UserID: \(userID.IDnum)")
    }
    
    // POST Requests
    
    func send_post(endpoint: String, parameters: Parameters) -> NSDictionary{
        var done = 0
        NSLog("PARAMETERS: \(parameters)")
        NSLog("URL: \(ROOTURL+endpoint)")
        var json: NSDictionary = NSDictionary()
        Alamofire.request(ROOTURL+endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HEADERS).responseJSON { response in
            NSLog("RESPONSE: \(response)")
            if let value = response.result.value {
                NSLog("VALUE: \(value)")
                json = (value as! NSDictionary)
                done = 1
            } else {
                done = 1
            }
            
        }
        
       while (done == 0) {
           RunLoop.current.acceptInput(forMode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture)
        }
        
        NSLog("JSON: \(json)")
        return json
    }
    
    func enter_location(loc_num: String) {
        NSLog("USERID: \(userID.IDnum)")
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "loc_number": loc_num
        ]
        
        _ = send_post(endpoint: "enter-location", parameters: parameters)
    }
    
    func exit_location(loc_num: String) {
        NSLog("USERID: \(userID.IDnum)")
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "loc_number": loc_num
        ]
        
        _ = send_post(endpoint: "exit-location", parameters: parameters)
    }
    
    func exit_all() {
        let parameters:Parameters = [
            "userid": userID.IDnum
        ]
        
        let resp = send_post(endpoint: "exit-all", parameters: parameters)
        NSLog("Exiting all: \(resp)")
    }
    
    func add_user(username: String, phonenumber: String) -> String {
        let parameters: Parameters = [
            "username": username,
            "phonenumber": phonenumber
        ]
        
        let json = send_post(endpoint: "add-user", parameters: parameters)
        
        return String(json.object(forKey: "userid")! as! Int)
    }
    
    func update_user_info(username: String, userid: String) {
        let parameters: Parameters = [
            "username": username,
            "userid": userid
        ]
        
        _ = send_post(endpoint: "update-user-info", parameters: parameters)
    }
    
    
    func create_group(groupname: String, locs: NSArray) ->String{
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupname": groupname,
            "locs": locs
        ]
        
        let json = send_post(endpoint: "create-group", parameters: parameters)
        
        return String(json.object(forKey: "groupid")! as! Int)
        
    }
    
    func join_group(groupid: String, locs:NSArray){
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupid": groupid,
            "locs": locs
        ]
        
        _ = send_post(endpoint: "join-group", parameters: parameters)
    }
    
    func join_group_for_user(friendUserID: String ,groupid: String, locs:NSArray){
        let parameters: Parameters = [
            "userid": friendUserID,
            "groupid": groupid,
            "locs": locs
        ]
        
        _ = send_post(endpoint: "join-group", parameters: parameters)
    }
    
    func leave_group(groupid: String){
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupid": groupid
        ]
        
        _ = send_post(endpoint: "leave-group", parameters: parameters)
    }
    
    func invite_to_group(groupid: String, phonenumber: String) -> NSDictionary{
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupid": groupid,
            "phonenumber": phonenumber
        ]
        
        let json = send_post(endpoint: "invite-to-group", parameters: parameters)
        
        return json
    }
    
    func respond_invite(inviteid: String, accept: Int, loc_numbers: NSArray){
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "inviteid": inviteid,
            "accept": accept,
            "loc_numbers": loc_numbers
        ]
        
        //print(parameters)
        _ = send_post(endpoint: "respond-invite", parameters: parameters)
    }
    
    func change_group_locations(groupid: String, locs: NSArray) {
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupid": groupid,
            "loc_numbers": locs
        ]
        
        _ = send_post(endpoint: "change-group-locations", parameters: parameters)
    }
    
    
    func set_invisible(groupid: String, is_invisible: Int){
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "groupid": groupid,
            "value": is_invisible
        ]
        
        _ = send_post(endpoint: "set-invisible", parameters: parameters)
    }
    
    
    func change_location_names(loc_dict: NSDictionary){
        let parameters: Parameters = [
            "userid": userID.IDnum,
            "loc_dict": loc_dict
        ]
        
        _ = send_post(endpoint: "change-location-names", parameters: parameters)
    }
    
    
    // GET requests
    
    func send_get(endpoint: String, headers: HTTPHeaders) -> NSDictionary{
        var done = 0
        //        NSLog("HEADERS: \(headers)")
        //        NSLog("URL: \(ROOTURL+endpoint)")
        var json: NSDictionary = NSDictionary()
        Alamofire.request(ROOTURL+endpoint, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //            NSLog("RESPONSE: \(response)")
            if let value = response.result.value {
                //                NSLog("VALUE: \(value)")
                json = value as! NSDictionary
                done = 1
            } else {
                done = 1
            }
        }
    
        while (done == 0) {
            RunLoop.current.acceptInput(forMode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture)
       }
        
        return json
    }
    
    func lookup_user(phonenumber: String) -> NSDictionary {
        var headers: HTTPHeaders = HEADERS
        headers["phonenumber"] = phonenumber
        
        let json = send_get(endpoint: "lookup-user", headers: headers)
        return(removeSuccess(dict: json))
        
    }
    
    func get_group_members(groupid: String) -> NSDictionary {
        var headers: HTTPHeaders = HEADERS
        headers["groupid"] = groupid
        
        let json = send_get(endpoint: "get-group-members", headers: headers)
        return(removeSuccess(dict: json))
    }
    
    func get_user_groups(userid: String) -> NSDictionary {
        var headers: HTTPHeaders = HEADERS
        headers["userid"] = userid
        
        let json = send_get(endpoint: "get-user-groups", headers: headers)
        return(removeSuccess(dict: json))
    }
    
    func check_invites() -> NSDictionary{
        var headers: HTTPHeaders = HEADERS
        headers["userid"] = userID.IDnum
        
        return send_get(endpoint: "check-invites", headers: headers)
    }
    
    func get_location(userid: String, groupid: String) -> NSDictionary {
        var headers = HEADERS
        headers["userid"] = userid
        headers["groupid"] = groupid
        
        let json = send_get(endpoint: "get-location", headers: headers)
        //return json[userid] as! String
        return removeSuccess(dict: json)
    }
    
    func get_location_names(userid: String, groupid: String) -> NSArray {
        var headers = HEADERS
        headers["userid"] = userid
        headers["groupid"] = groupid
        
        let json = send_get(endpoint: "get-location", headers: headers)
        return json.object(forKey: "locations")! as! NSArray
    }
    
    // Removes "Success = 1" from a dictionary
    func removeSuccess(dict: NSDictionary) -> NSDictionary {
        let dict2: NSMutableDictionary = NSMutableDictionary()
        for key in dict.allKeys {
            let keyString:String = key as! String
            if (keyString != "Success") {
                dict2[key] = dict[key]
            }
        }
        return dict2
    }
    
    
    
}
