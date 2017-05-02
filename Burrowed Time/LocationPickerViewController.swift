//
//  LocationPickerViewController.swift
//  Burrowed Time
//
//  Created by Katy on 4/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class LocationPickerViewController: UIViewController {
    var currentTitle:String!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBAction func unwindToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func cancelToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveNewPlace(unwindSegue: UIStoryboardSegue) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(currentTitle)
        locationNameLabel.text = currentTitle

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMapSettings") {
            let mapSettingsPage:MapGUIViewController! = segue.destination as! MapGUIViewController
            mapSettingsPage.currentTitle = currentTitle
        }
        
        if (segue.identifier == "groupCellSegue") {
            let locationPickerTable:LocationPickerTableViewController! = segue.destination as! LocationPickerTableViewController
            locationPickerTable.currentLocation = currentTitle
        }
    }
}
