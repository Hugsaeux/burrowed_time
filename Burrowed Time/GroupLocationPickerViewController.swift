//
//  GroupLocationPickerViewController.swift
//  Burrowed Time
//
//  Created by Katy on 4/11/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class GroupLocationPickerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    var groupName: String!
    var groupList: GroupList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = groupName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLocationCells") {
            let groupLocationTableView:GroupLocationPickerTableViewController! = segue.destination as! GroupLocationPickerTableViewController
            groupLocationTableView.groupList = groupList
            groupLocationTableView.currentGroup = groupName
        }
    }

}
