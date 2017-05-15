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
    
    var alertController:UIAlertController = UIAlertController(title: "Limit exceeded", message: "Only up to 7 locations can be assigned to each group.", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    let nc = NotificationCenter.default
    
    func alertLocationsExceeded(note:Notification) {
        self.present(self.alertController, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = groupName
        
        self.alertController.addAction(OKAction)
        nc.addObserver(forName:Notification.Name(rawValue:"GroupLocsExceeded"),
                       object:nil, queue:nil,
                       using:self.alertLocationsExceeded)
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
