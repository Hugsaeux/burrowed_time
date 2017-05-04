//
//  GroupInviteTableViewController.swift
//  Burrowed Time
//
//  Created by Sudikoff Lab iMac on 5/2/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class GroupInviteTableViewController: UITableViewController {

    var invites = [Invitation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let api:API = API()
        print("invite_started")
        let invitations = api.removeSuccess(dict: api.check_invites())
        
        for (inviteId, info) in invitations{
            let invite = Invitation(id:inviteId as! String, inviter:(info as! NSArray)[0] as! String, group:(info as! NSArray)[2] as! String)
            invites.append(invite)
        }
        
        for invite in invites{
            print(invite.getId())
            print(invite.getInviter())
            print(invite.getGroup())
        }
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
        return invites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GroupInviteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "inviteTableCell", for: indexPath) as! GroupInviteTableViewCell

        // Configure the cell...
        cell.friendLabel.text = invites[indexPath.row].getInviter()
        cell.groupLabel.text = invites[indexPath.row].getGroup()

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
