//
//  LocationPickerViewController.swift
//  Burrowed Time
//
//  Created by Katy on 4/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class LocationPickerViewController: UIViewController, UITextFieldDelegate {
    var currentTitle:String!
    var oldTitle:String!
    var groupList:GroupList!
    
    var alertController:UIAlertController = UIAlertController(title: "Limit exceeded", message: "Only up to 7 locations can be assigned to each group.", preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    
    let nc = NotificationCenter.default
    
    @IBOutlet weak var locationNameTextField: UITextField!
    
    @IBAction func unwindToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func cancelToLocationPicker(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveNewPlace(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        print("here")
    }

    func alertLocationsExceeded(note:Notification) {
        self.alertController.title = "Limit exceeded"
        self.alertController.message = "Only up to 7 locations can be assigned to each group."
        self.present(self.alertController, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationNameTextField.delegate = self
        
        locationNameTextField.text = currentTitle
        oldTitle = currentTitle
        
        groupList = GroupList()
        groupList.loadGroupListFromPhone()

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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var duplicateName:Bool = false
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        
        for region in locationUtil!.manager.monitoredRegions{
            let regionIdx = region.identifier
            let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
            
            if (String(describing: regionInfo[TITLE]) == locationNameTextField.text){
                duplicateName = true
            }
        }
        if (duplicateName){
            self.alertController.title = "Invalid Name"
            self.alertController.message = "This place name is already in use."
            self.present(self.alertController, animated: true, completion:nil)
        }else{
            textField.resignFirstResponder()
            currentTitle = locationNameTextField.text
            
            
            for region in locationUtil!.manager.monitoredRegions {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                let title = String(describing: regionInfo[TITLE])
                
                if (title == oldTitle) {
                    let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
                    let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
                    let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
                    let currInfo:NSArray = [currentTitle, latitude, longitude, radius]
                    storedRegionLookup.regionLookup[regionIdx] = currInfo
                    storedRegionLookup.saveRegionLookupToPhone()
                }
            }
            
            for group in groupList.groups {
                for location in group.locations {
                    if (location.name == oldTitle) {
                        location.name = currentTitle
                    }
                }
            }
            
            groupList.saveGroupListToPhone()
            oldTitle = currentTitle
            
            updateLocationNames()
        }
        return false
    }
}
