//
//  MapTableViewController.swift
//  Burrowed Time
//
//  Created by Katy on 2/5/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewController: UITableViewController {
    
    var cellTitles:[String] = [String]()
    
    func getCellData() {
        cellTitles = [String]()
        
        let cellData:RegionLookup = RegionLookup();
        cellData.loadRegionLookupFromPhone()
        
        for (_, value) in cellData.regionLookup {
            let data:NSArray = value as! NSArray
            cellTitles.append(data[0] as! String)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getCellData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (cellTitles.count)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationPickerPage:LocationPickerViewController! = self.storyboard?.instantiateViewController(withIdentifier: "LocationPicker") as! LocationPickerViewController
        
        locationPickerPage.currentTitle = cellTitles[indexPath.row]
        
        self.present(locationPickerPage, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MapTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MapTableCell", for: indexPath) as! MapTableViewCell
        
        cell.title.text = cellTitles[indexPath.row]
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the location from the data source
            let storedRegionLookup = RegionLookup()
            storedRegionLookup.loadRegionLookupFromPhone()
            let storedRegionIdx = RegionIdx()
            storedRegionIdx.loadRegionIdxFromPhone()

            let cell:MapTableViewCell = tableView.cellForRow(at: indexPath) as! MapTableViewCell
            let deletedTitle:String = cell.title.text!
            NSLog("Attempted to delete \(deletedTitle)")
            
            let newLookup = NSMutableDictionary()
            let oldToNewID = NSMutableDictionary()  // Lookup new integer ID using old string ID
            let locDict = NSMutableDictionary()
            var newIdx = 0
            
            for region in locationUtil!.manager.monitoredRegions {
                locationUtil!.manager.stopMonitoring(for: region)
                
                print("At time of delete manager was monitoring the region: \(region)")
                let info:NSArray = storedRegionLookup.regionLookup.object(forKey: region.identifier) as! NSArray
                if (info[TITLE] as! String != deletedTitle) {
                    let lat = NumberFormatter().number(from: String(describing: info[LATITUDE]))!.doubleValue
                    let long = NumberFormatter().number(from: String(describing: info[LONGITUDE]))!.doubleValue
                    let rad = NumberFormatter().number(from: String(describing: info[RADIUS]))!.doubleValue
                    
                    let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let currRegion = CLCircularRegion(center: center, radius: rad, identifier: String(newIdx))
                    locationUtil!.manager.startMonitoring(for: currRegion)
                    
                    newLookup[newIdx.description] = info
                    oldToNewID[region.identifier] = newIdx
                    locDict[newIdx.description] = info[TITLE]
                    newIdx += 1
                }
                else {
                    let api:API = API()
                    api.exit_location(loc_num: region.identifier)
                }
            }
            
            let newRegionLookup = RegionLookup(regionLookup: newLookup)
            newRegionLookup.saveRegionLookupToPhone()
            
            // Decrement index
            storedRegionIdx.decrementIdx()
            storedRegionIdx.saveRegionIdxToPhone()
            
            // Delete the location from the database
            locDict[storedRegionIdx.regionIdx] = NSNull()
            let api:API = API()
            api.change_location_names(loc_dict: locDict)
            
            // Update current location in database
            updateCurrentLocation()
            
            // Rename locations in groupList
            let groupList:GroupList = GroupList()
            groupList.loadGroupListFromPhone()
            
            for group:Group in groupList.groups {
                let groupid = group.getIdentifier()
                let locs = NSMutableArray()
                for location:Location in group.locations {
                    if (location.name == cell.title.text) {
                        api.change_group_locations(groupid: group.getIdentifier(), locs: [])
                        group.removeLocation(location: location.name)
                    } else {
                        let oldID = String(location.getLocationID())
                        let newID = oldToNewID[oldID] as! Int
                        location.setLocationID(newID: newID)
                        locs.add(newID)
                    }
                }
//                NSLog("GROUPID: \(groupid)")
//                NSLog("\(locs)")
                api.change_group_locations(groupid: groupid, locs: locs)
            }
            groupList.saveGroupListToPhone()
            
//            for region in locationUtil!.manager.monitoredRegions {
//                // Make a new annotation for this region
//                let regionIdx = region.identifier
//                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
//                
//                //check if in bounds
//                let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
//                let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
//                let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
//                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                let ourLocation = locationUtil!.manager.location
//                let clLocCoor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                let distance = ourLocation?.distance(from: clLocCoor)
//                
//                if ((distance! as Double) < radius) {
//                    api.enter_location(loc_num: regionIdx)
//                }
//                else {
//                    api.exit_location(loc_num: regionIdx)
//                }
//            }
            
            cellTitles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            

        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
