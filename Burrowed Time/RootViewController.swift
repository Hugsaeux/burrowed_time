//
//  RootViewController.swift
//  Burrowed Time
//
//  Created by Katy on 1/18/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit
import Alamofire

let TRAVELING = "0" // Constant location number for traveling
// Region Info Array Indices
let TITLE = 0
let LATITUDE = 1
let LONGITUDE = 2
let RADIUS = 3

var firstLoad = true

let HEADERS: HTTPHeaders = [ // Constant headers for database communication
    "Content-Type": "application/json",
    "Host": "i0qesl17of.execute-api.us-east-2.amazonaws.com",
    "X-Amz-Date": "20170129T223359Z",
    "Authorization": "AWS4-HMAC-SHA256 Credential=AKIAIPJV5BLTTE2LSX2A/20170129/us-east-2/execute-api/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=99cdb153417ff0140639c0a91df088f18e22f40739862af2082594c015336550"
]

let ROOTURL:String = "https://i0qesl17of.execute-api.us-east-2.amazonaws.com/prod/burrowed_time/"

class RootViewController: UIViewController, UIPageViewControllerDelegate, UITableViewDelegate {
    var pageViewController: UIPageViewController?
    var passedData: String = ""
    var currentIndex: Int = 0
    
    // unwind segues
    @IBAction func cancelToMainUnwindAction(unwindSegue: UIStoryboardSegue) {
        refreshView(currentPage: 0, editingMode: false)
    }
    
    @IBAction func removeGroupUnwindAction(unwindSegue: UIStoryboardSegue) {
        currentIndex = 0
        refreshView(currentPage: 0, editingMode: true)
    }
    
    @IBAction func saveAddFriendUnwindAction(unwindSegue: UIStoryboardSegue) {
        //currentIndex +=1
        currentIndex = UserDefaults.standard.integer(forKey: "homePageIndex")
        refreshView(currentPage: currentIndex, editingMode: false)
    }
    
    @IBAction func saveNewGroupUnwindAction(unwindSegue: UIStoryboardSegue) {
        currentIndex = 0
        refreshView(currentPage: 0, editingMode: false)
    }
    
    @IBAction func saveUserSettingsUnwindAction(unwindSegue: UIStoryboardSegue) {
        currentIndex = 0
        refreshView(currentPage: 0, editingMode: false)
    }
    
    @IBAction func homeTableCellClicked(unwindSegue: UIStoryboardSegue) {
        refreshView(currentPage: currentIndex, editingMode: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userid:UserID = UserID(IDnum: "", userName: "", phoneNumber: "")
        
        if (!userid.loadUserIDFromPhone()) {
            let loginScreen:UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen")
            self.present(loginScreen, animated: true, completion: nil)
            firstLoadSetup()
        }
        else {
            refreshView(currentPage: currentIndex, editingMode: false)
        }
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

        return .mid
    }
    
    func refreshView(currentPage: Int, editingMode: Bool) {
        _modelController = ModelController()
        _modelController?.editingMode = editingMode
        modelController.startingPage = currentPage
        self.pageViewController?.dataSource = _modelController
        
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(currentPage, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMove(toParentViewController: self)
    }
    
    func firstLoadSetup() {
        let regionLookup = RegionLookup()
        regionLookup.saveRegionLookupToPhone()
        
        let regionIdx = RegionIdx()
        regionIdx.saveRegionIdxToPhone()
    }
}

