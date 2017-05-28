//
//  HomeTableViewController.swift
//  Burrowed Time
//
//  Created by Katy on 1/22/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

protocol HomeTableViewDelegate {
    func cellClicked(index:Int)
}

class HomeTableViewController: UITableViewController {
    @IBOutlet weak var cellTitle: UILabel!
    
    var cellData:GroupList = GroupList()
    var index:Int = 0
    var clickIndex = 0
    var dataViewController:DataViewController!
    var refresh = UIRefreshControl()
    var editingMode:Bool!
    var pageID:String = ""
    
    func refreshTable(_ sender : UIRefreshControl) {
        refreshData()
        refresh.endRefreshing()
    }
    
    func refreshData() {
        if (index != 0) {
            refreshGroupInfo(group: cellData.groups[index-1])
        }
        else {
            let api = API()
            let userID:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
            _ = userID.loadUserIDFromPhone()
            
            let groups:NSDictionary = api.get_user_groups(userid: userID.IDnum)
            
            for (key, value) in groups {
                if (self.cellData.checkGroupID(id: key as! String)) {
                    let newGroup:Group = Group(groupName: value as! String)
                    newGroup.setIdentifier(id: key as! String)
                    self.cellData.addGroup(group: newGroup)
                }
                else {
                    self.cellData.groups[self.cellData.getIndexOfGroup(groupID: key as! String)].groupName = value as! String
                }
            }
        }
        
        self.cellData.saveGroupListToPhone()
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = refresh
        
        refresh.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (index == 0) {
            return cellData.getSize()
        }
        else {
            if (cellData.groups.count > 0) {
                return cellData.groups[index-1].getSize()
            }
            else {
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "homeScreenGroupCell", for: indexPath) as! HomeTableViewCell
        
        cell.groupList = cellData
        cell.dataViewController = dataViewController
        
        if (cellData.getSize() > 0) {
            if (index == 0) {
                cell.cellTitle.text = cellData.groups[indexPath.row].getGroupName()
                cell.cellLocation.text = ""
                cell.invisibilitySwitch.isHidden = false
                let visible = cellData.groups[indexPath.row].visibility
                cell.invisibilitySwitch.isOn = visible
                cell.eyeClosedIcon.isHidden = visible
                cell.eyeOpenIcon.isHidden = !visible
                cell.cellID = cellData.groups[indexPath.row].getIdentifier()
                
                if (self.isEditing) {
                    cell.invisibilitySwitch.isHidden = true
                    cell.eyeClosedIcon.isHidden = true
                    cell.eyeOpenIcon.isHidden = true
                }
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyle.none;
                cell.cellTitle.text = cellData.groups[index-1].members[indexPath.row].getName()
                cell.cellLocation.text = cellData.groups[index-1].members[indexPath.row].location
                cell.invisibilitySwitch.isHidden = true
                cell.eyeClosedIcon.isHidden = true
                cell.eyeOpenIcon.isHidden = true
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (index == 0) {
            clickIndex = indexPath.row+1
            self.performSegue(withIdentifier: "homeTableCellClicked", sender: self)
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingMode) {
            if editingStyle == .delete {
                let group:Group = cellData.groups[indexPath.row]
                
                let api:API = API()
                api.leave_group(groupid: group.getIdentifier())
                
                cellData.removeGroup(groupID: cellData.groups[indexPath.row].getIdentifier())
                cellData.saveGroupListToPhone()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let root:RootViewController! = segue.destination as! RootViewController
        root.currentIndex = clickIndex
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
