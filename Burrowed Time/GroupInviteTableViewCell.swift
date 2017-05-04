//
//  GroupInviteTableViewCell.swift
//  Burrowed Time
//
//  Created by Sudikoff Lab iMac on 5/2/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class GroupInviteTableViewCell: UITableViewCell {

    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    
    var inviteId:String!
    
    let api:API = API()
    
    @IBAction func acceptButtonClick(_ sender: Any) {
        api.respond_invite(inviteid: inviteId, accept: 1, loc_numbers: [])
        print("accepted")
    }
    
    @IBAction func rejectButtonClick(_ sender: Any) {
        api.respond_invite(inviteid: inviteId, accept: 0, loc_numbers: [])
        print("rejected")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
