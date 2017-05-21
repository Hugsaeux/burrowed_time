//
//  ModelController.swift
//  Burrowed Time
//
//  Created by Katy on 1/18/17.
//  Copyright © 2017 Dartmouth COSC 98. All rights reserved.
//

import UIKit

class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [String] = []
    var window: UIWindow?
    var startingPage: Int = 0
    var editingMode: Bool = false

    override init() {
        super.init()
        pageData = ["Burrowed Time"]
    }

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        
        let groupList:GroupList = GroupList()
        groupList.loadGroupListFromPhone()
        
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) {
            return nil
        }
        
        //if 0 show the grouplist
        //if >= 1 show the friends in the grouplist of the int

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        
        dataViewController.groupList = groupList
        
        dataViewController.numberOfPages = dataViewController.groupList.getSize()+1;
        dataViewController.currentPage = index
     
        if (self.pageData.count-1 != dataViewController.groupList.getSize()) {
            for group in groupList.groups {
                pageData.append(group.getGroupName())
            }
        }
        
        if (index >= 1 && index <= dataViewController.groupList.getSize()) {
            dataViewController.pageTitle = dataViewController.groupList.groups[index-1].getGroupName()
            dataViewController.pageID = dataViewController.groupList.groups[index-1].getIdentifier()
        }
        
        if (editingMode) {
            dataViewController.editingMode = true;
        }
        
        return dataViewController
    }

    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return viewController.currentPage
    }
    
    func maxOfViewController(_ viewController: DataViewController) -> Int {
        return viewController.groupList.groups.count+1
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            index = self.maxOfViewController(viewController as! DataViewController)
        }
        index -= 1
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        index += 1
        
        if index == self.pageData.count {
            index = 0
        }
    
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
}

