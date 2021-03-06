//
//  MapGUIViewController.swift
//  Burrowed Time
//
//  Created by Hugsaeux on 2/19/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//
import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
    }
    
    func setCoordinate (coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

func updateLocationNames(){
    let storedRegionLookup = RegionLookup()
    storedRegionLookup.loadRegionLookupFromPhone()
    let api:API = API()
    let locDict = NSMutableDictionary()
    
    for region in locationUtil!.manager.monitoredRegions {
        let info:NSArray = storedRegionLookup.regionLookup.object(forKey: region.identifier) as! NSArray
        locDict[region.identifier] = info[TITLE]
    }
    api.change_location_names(loc_dict: locDict)
}

func updateCurrentLocation(){
    let storedRegionLookup = RegionLookup()
    storedRegionLookup.loadRegionLookupFromPhone()
    let api:API = API()
    
    api.exit_all()
    
    for region in locationUtil!.manager.monitoredRegions {
        let regionIdx = region.identifier
        let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
        
        //check if in bounds
        let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
        let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
        let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let ourLocation = locationUtil!.manager.location
        let clLocCoor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = ourLocation?.distance(from: clLocCoor)
        
        if ((distance! as Double) < radius) {
            api.enter_location(loc_num: regionIdx)
        }
    }
}

class MapGUIViewController: UIViewController, MKMapViewDelegate {
    var currentTitle:String!
    var currentRadius:CLLocationDistance = 100
    var currentIdx:String = "-1"
    var addLocationFlag:Bool = false
    var currentCoordinate:CLLocationCoordinate2D!
    var saveLocationFlag:Bool = false
    var currentAnnotation:LocationAnnotation!
    
    var alertController:UIAlertController = UIAlertController(title: "Location Not Added", message: "Please drop a new location pin to save.", preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "Okay", style: .default) { (action:UIAlertAction!) in
        print("you have pressed Okay button");
        //Do something with the button press maybe
    }
    
    
    @IBOutlet weak var mapTitle: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var cancelToLocationButton: UIBarButtonItem!
    @IBOutlet weak var backArrow: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        if (addLocationFlag) {
            NSLog("currentTitle = \(currentTitle) : longPressed")
            let annotation:LocationAnnotation = LocationAnnotation(title: currentTitle, coordinate: locationCoordinate)
    
            radiusOverlay(center: annotation.coordinate, radius: currentRadius)
            
            mapView.addAnnotation(annotation)
            currentAnnotation = annotation
            currentCoordinate = locationCoordinate
            
            saveButton.tintColor = UIColor.black
            
            addLocationFlag = false
            saveLocationFlag = true
        }
        else{
            currentCoordinate = locationCoordinate
            
            mapView.removeAnnotation(currentAnnotation)
            mapView.removeOverlays(mapView.overlays)
            
            currentAnnotation.coordinate = currentCoordinate
            mapView.addAnnotation(currentAnnotation)
            radiusOverlay(center: currentCoordinate, radius: currentRadius)
            
            saveButton.tintColor = UIColor.black
        }
    }
    
    @IBAction func radiusSliderAction(_ sender: Any) {
        if (currentCoordinate != nil) {
            currentRadius = Double(radiusSlider.value)
            mapView.removeOverlays(mapView.overlays)
        
            radiusOverlay(center: currentCoordinate, radius: currentRadius)
        }
    }
    
    @IBAction func currentLocationButtonPress(_ sender: Any) {        
        let mapLat = mapView.centerCoordinate.latitude
        let mapLong = mapView.centerCoordinate.longitude
        let userLat = locationUtil!.manager.location!.coordinate.latitude
        let userLong = locationUtil!.manager.location!.coordinate.longitude
        let tolerance = 0.0001
        if (((abs(mapLat - userLat)) < tolerance) && (abs(mapLong - userLong) < tolerance) && mapView.showsUserLocation) {
            mapView.showsUserLocation = false
            mapView.setUserTrackingMode(.none, animated: true)
            currentLocationButton.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: UIControlState.normal)
            currentLocationButton.backgroundColor = #colorLiteral(red: 0.6916844249, green: 0.9323277473, blue: 0.9025284648, alpha: 1)
        } else {
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
            currentLocationButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            currentLocationButton.backgroundColor = #colorLiteral(red: 0.5649450421, green: 0.8466786742, blue: 0.6952821612, alpha: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("currentTitle = \(currentTitle) : viewDidLoad")
        mapTitle.title = currentTitle
        
        self.alertController.addAction(OKAction)
        
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        
        for region:CLRegion in locationUtil!.manager.monitoredRegions {
            // Make a new annotation for this region
            let regionIdx = region.identifier
            let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
            let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
            let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
            let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let title = String(describing: regionInfo[TITLE])
            let annotation:LocationAnnotation = LocationAnnotation(title: title, coordinate: coordinate)
            
            if (title == currentTitle) {
                let mapRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
                mapView.setRegion(mapRegion, animated: true)
                radiusSlider.setValue(Float(radius), animated: true)
                currentRadius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
                currentIdx = regionIdx
                currentCoordinate = coordinate
                currentAnnotation = annotation
            }
            
            mapView.addAnnotation(annotation)
        }
        
        // If currentTitle is not a currently monitored region, its currentIdx should be the next available index
        if (currentIdx == "-1") {
            let storedRegionIdx = RegionIdx()
            storedRegionIdx.loadRegionIdxFromPhone()
            currentIdx = storedRegionIdx.regionIdx as String
        }
        
        mapView.delegate = self
        
        if (addLocationFlag) {
            cancelToLocationButton.isEnabled = false
            cancelToLocationButton.tintColor = #colorLiteral(red: 0.6916844249, green: 0.9323277473, blue: 0.9025284648, alpha: 1)
            backArrow.isHidden = false
            let tap = UITapGestureRecognizer(target: self, action:#selector(MapGUIViewController.clickBack))
            backArrow.addGestureRecognizer(tap)
//            mapView.showsUserLocation = true
//            mapView.setUserTrackingMode(.follow, animated: false)
            let noLocation = CLLocationCoordinate2D()
            let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 200, 200)
            mapView.setRegion(viewRegion, animated: false)
            
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
            
            
//            let mapRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
//            mapView.setRegion(mapRegion, animated: true)
        }
        
        if (mapView.showsUserLocation){
            currentLocationButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            currentLocationButton.backgroundColor = #colorLiteral(red: 0.5649450421, green: 0.8466786742, blue: 0.6952821612, alpha: 1)
        }
    }
    
    func clickBack(sender:UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "cancelToMapTable", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKPinAnnotationView
        guard let annotation = annotation as? LocationAnnotation else {return nil}
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.title!) as? MKPinAnnotationView {
            return view
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.title)
            view.isEnabled = true
            view.canShowCallout = true
            NSLog("currentTitle = \(currentTitle) : MKAnnotationView")
            if (annotation.title! == currentTitle) {
                view.pinTintColor = UIColor.green
                view.isDraggable = true
                radiusOverlay(center: annotation.coordinate, radius: currentRadius)
            }
            return view
        }
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        // Allows user to drop a pin directly on top of the blue current location beacon
        if (mapView.isUserLocationVisible) {
            let currentLocationAnnotationView:MKAnnotationView = mapView.view(for: mapView.userLocation)!
            currentLocationAnnotationView.isEnabled = false // Disable interaction with the beacon

        }
    }

    // Dragging the pin
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        NSLog("currentTitle = \(currentTitle) : MKAnnotationViewDragState")
        if (newState == MKAnnotationViewDragState.starting) {
            mapView.removeOverlays(mapView.overlays)
        }
        
        if (newState == MKAnnotationViewDragState.ending) {
            radiusOverlay(center: view.annotation!.coordinate, radius: currentRadius)
            currentCoordinate = view.annotation!.coordinate
            saveButton.tintColor = UIColor.black
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.blue
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func radiusOverlay(center:CLLocationCoordinate2D, radius:CLLocationDistance) {
        let center = center
        let circle = MKCircle(center: center, radius: radius)
        mapView.add(circle)
    }
    
    func addRegion(center: CLLocationCoordinate2D, radius: Double, currInfo: NSArray) {
        let storedRegionLookup = RegionLookup()
        storedRegionLookup.loadRegionLookupFromPhone()
        let storedRegionIdx = RegionIdx()
        storedRegionIdx.loadRegionIdxFromPhone()
        
        let currRegion = CLCircularRegion.init(center: center, radius: radius, identifier: String(storedRegionIdx.regionIdx))
        storedRegionLookup.regionLookup[storedRegionIdx.regionIdx] = currInfo
        storedRegionIdx.incrementIdx()
        
        storedRegionLookup.saveRegionLookupToPhone()
        storedRegionIdx.saveRegionIdxToPhone()
        locationUtil!.manager.startMonitoring(for: currRegion)
        NSLog("Manager is monitoring: \(locationUtil!.manager.monitoredRegions)")
    }
    
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let api:API = API()
        
        NSLog("currentTitle = \(currentTitle) : prepare for segue")
        // Save a new location
        if (addLocationFlag && segue.identifier == "saveNewPlace"){
            self.present(self.alertController, animated: true, completion:nil)
        }
        else if (segue.identifier == "saveNewPlace" && saveLocationFlag) {
            let currInfo:NSArray = [currentTitle, currentCoordinate.latitude, currentCoordinate.longitude, String(currentRadius)]
            addRegion(center: currentCoordinate, radius: currentRadius, currInfo: currInfo)

            var locations = [String]()
            var indices = [String]()
            
            let storedRegionLookup = RegionLookup()
            storedRegionLookup.loadRegionLookupFromPhone()
            for region in locationUtil!.manager.monitoredRegions {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                let title = String(describing: regionInfo[TITLE])
                
                locations.append(title)
                indices.append(regionIdx)
                
                if (title == currentTitle) {
                    //check if in bounds
                    let latitude = NumberFormatter().number(from: String(describing: regionInfo[LATITUDE]))!.doubleValue
                    let longitude = NumberFormatter().number(from: String(describing: regionInfo[LONGITUDE]))!.doubleValue
                    let radius = NumberFormatter().number(from: String(describing: regionInfo[RADIUS]))!.doubleValue
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let ourLocation = locationUtil!.manager.location
                    let clLocCoor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let distance = ourLocation?.distance(from: clLocCoor)
                    
                    if ((distance! as Double) < radius) {
                        api.enter_location(loc_num: regionIdx)
                    }else{
                        api.exit_location(loc_num: regionIdx)
                    }
                }
            }
            
            let locationDictionary:NSDictionary = NSDictionary(objects:  locations, forKeys: indices as [NSCopying])
            api.change_location_names(loc_dict: locationDictionary)
        
            let locationPickerPage:LocationPickerViewController! = self.storyboard?.instantiateViewController(withIdentifier: "LocationPicker") as! LocationPickerViewController
            locationPickerPage.currentTitle = self.currentTitle
            
            self.present(locationPickerPage, animated: true, completion: nil)
        }
            
        // resave an old location
        else if (segue.identifier == "saveNewPlace") {
            let storedRegionLookup = RegionLookup()
            storedRegionLookup.loadRegionLookupFromPhone()
            
            for region in locationUtil!.manager.monitoredRegions {
                // Make a new annotation for this region
                let regionIdx = region.identifier
                let regionInfo:NSArray = storedRegionLookup.regionLookup.object(forKey: regionIdx) as! NSArray
                let title = String(describing: regionInfo[TITLE])
                
                if (title == currentTitle) {
                    let storedRegionLookup = RegionLookup()
                    storedRegionLookup.loadRegionLookupFromPhone()
                    let currInfo:NSArray = [currentTitle, currentCoordinate.latitude, currentCoordinate.longitude, currentRadius]
                    storedRegionLookup.regionLookup[currentIdx] = currInfo
                    storedRegionLookup.saveRegionLookupToPhone()
                    
                    // Stop location manager monitoring of old region
                    for region:CLRegion in locationUtil!.manager.monitoredRegions {
                        if (region.identifier == currentIdx) {
                            locationUtil!.manager.stopMonitoring(for: region)
                        }
                    }
                    
                    // Start location manager monitoring new region
                    let currRegion = CLCircularRegion.init(center: currentCoordinate, radius: currentRadius, identifier: currentIdx)
                    NSLog("Manager is monitoring AFTER STOPPING: \(locationUtil!.manager.monitoredRegions)")
                    
                    locationUtil!.manager.startMonitoring(for: currRegion)
                    NSLog("Manager is monitoring AFTER STARTING: \(locationUtil!.manager.monitoredRegions)")
                    
                    //check if in bounds
                    let ourLocation = locationUtil!.manager.location
                    let clLocCoor = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
                    let distance = ourLocation?.distance(from: clLocCoor)
                    
                    
                    
                    if ((distance! as Double) < currentRadius) {
                        api.enter_location(loc_num: regionIdx)
                    }
                    else {
                        api.exit_location(loc_num: regionIdx)
                    }
                }
            }
            
            let locationPickerPage:LocationPickerViewController! = self.storyboard?.instantiateViewController(withIdentifier: "LocationPicker") as! LocationPickerViewController
            
            locationPickerPage.currentTitle = self.currentTitle
            print(self.currentTitle)
            
            self.present(locationPickerPage, animated: true, completion: nil)
        }
    }
}
