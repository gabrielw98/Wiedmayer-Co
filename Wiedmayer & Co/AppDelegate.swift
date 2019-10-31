//
//  AppDelegate.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import UIKit
import Parse
import WLEmptyState
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /* COMPLETE */
    //*Properties deletion
    //*Properties update db
    //*Profile send app to colleague
    //*Update & delete only accessible to admin
    //*Profile admin send grid
    //*Profile Icon and mission statement
    //*Dropdown for auto filling address field
    //*Update existing property image
    //*Change Settings to allow users to report bugs directly to me
    //*Make proerty details less static (consider LinkedIn like viewing)
    //*Edit the name and the address (from property details)
    //*Build out details collection view
    //*Build out details bottom view
    //*Get the correct property attributes
    //*Notify user on login failure
    //*Login shake animation when input is invalid
    //*Add state and zipcode to the address
    //*Add edit icon above "Name"
    //*Don't show login screen on loading
    
    /* IN PROGRESS */
    // Search table view by name
    // Gracefully handle connectivity issues
    // Potentially remove tab bar and replace with a fan menu
    
    /* BACK LOG */
    // Cache the properties in sql db so I dont have to retrieve them every time the app is opened and closed
    // Create property image constraints
    // Address Dropdown scrollable
    // Edit Property Type add dropdown
    // Refactor AppDelegate query and setup admin to launch vc
    // Add Skeleton View
    
     var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Configure Parse client
        let configuration = ParseClientConfiguration {
            $0.applicationId = "eWBpWgr9JEQjC3mkfYgAoN5XwVw0qjiz1W5mmQvW"
            $0.clientKey = "XlZgc342N2FS7E6hJ1IP4fF3Hi7DXSUzjUCgnKy6"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        // Empty tableview framework
        WLEmptyState.configure()
        
        UINavigationBar.appearance().barTintColor = UIColor.darkGray
        UINavigationBar.appearance().tintColor = UIColor(red: 225/255, green: 198/255, blue: 153/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 225/255, green: 198/255, blue: 153/255, alpha: 1)]
        
        UITextField.appearance().tintColor = UIColor.darkGray
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        queryProperties()
        
        return true
    }
    
    func setupAdminStatus() {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground { (object, error) in
            if (error != nil) {
                print("CAPTURED NETWORK ERROR")
            }
            if object != nil {
                if let adminStatus = object!["isAdmin"] {
                    DataModel.adminStatus = adminStatus as! Bool
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func queryProperties() {
        let query = PFQuery(className: "Property")
        query.addDescendingOrder("createdAt")
        query.limit = 100
        let propertyRef = Property()
        propertyRef.getProperties(query: query, completion: { (propertyObjects) in
            DataModel.properties = propertyRef.orderByCreatedAtAscending(properties: propertyObjects)
            if PFUser.current() != nil {
                self.setupAdminStatus()
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignUpVC")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        })
    }
}

