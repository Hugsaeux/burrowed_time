//
//  AddressBookTableCellViewCell.swift
//  Burrowed Time
//
//  Created by Katy on 3/1/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class AddressBookTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
