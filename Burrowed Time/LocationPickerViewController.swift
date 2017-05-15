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
    
    var alertController:UIAlertController = UIAlertController(title: "Limit exceeded", message: "Only up to 7 locations can be assigned to each group.", preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    
    let nc = NotificationCenter.default
    
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBAction func unwindToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func cancelToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveNewPlace(unwindSegue: UIStoryboardSegue) {}

    func alertLocationsExceeded(note:Notification) {
        self.present(self.alertController, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(currentTitle)
        locationNameLabel.text = currentTitle

        // Do any additional setup after loading the view.
        
        self.alertController.addAction(OKAction)
        nc.addObserver(forName:Notification.Name(rawValue:"LocPickerLocsExceeded"),
                       object:nil, queue:nil,
                       using:self.alertLocationsExceeded)
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
