//
//  MapParentViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class MapParentViewController: UIViewController {
    var table:MapTableViewController!
    
    // unwind segues
    @IBAction func cancelToMapTable(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveNewPlaceUnwindAction(unwindSegue: UIStoryboardSegue) {
        self.table.getCellData()
        self.table.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "mapTableSegue") {
            table = segue.destination as! MapTableViewController
        }
    }

}
