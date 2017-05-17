//
//  AddPlaceViewController.swift
//  Burrowed Time
//
//  Created by Katy on 3/4/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class AddPlaceViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var placeTitleTextbox: UITextField!
    
    var alertController:UIAlertController = UIAlertController(title: "Invalid name", message: "This place name is already in use.", preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        if (placeTitleTextbox.text != "") {
            let storedRegionLookup:RegionLookup = RegionLookup();
            storedRegionLookup.loadRegionLookupFromPhone()
            
            var repeatedName:Bool = false
            
            for (_, value) in storedRegionLookup.regionLookup {
                let data:NSArray = value as! NSArray
                if (data[TITLE] as? String == placeTitleTextbox.text){
                    repeatedName = true
                }
            }
            
            if (repeatedName){
                self.present(self.alertController, animated: true, completion:nil)
            }else{
                let mapSettingsPage:MapGUIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "MapSettingsPage") as! MapGUIViewController
            
                mapSettingsPage.currentTitle = placeTitleTextbox.text
                mapSettingsPage.addLocationFlag = true
                
                self.present(mapSettingsPage, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeTitleTextbox.delegate = self
        self.alertController.addAction(OKAction)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
