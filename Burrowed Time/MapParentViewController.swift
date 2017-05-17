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
    
    var alertController:UIAlertController = UIAlertController(title: "Limit exceeded", message: "Only up to 20 total locations can be saved.", preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    
    // unwind segues
    @IBAction func cancelToMap(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveNewPlaceUnwindAction(unwindSegue: UIStoryboardSegue) {
        self.table.getCellData()
        self.table.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.alertController.addAction(OKAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newLocationButtonPressed(_ sender: Any) {
        if (self.table.cellTitles.count >= 20){
        self.present(self.alertController, animated: true, completion:nil)
        }
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
