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
    
    /* IN PROGRESS */
    // Create property image constraints
    // Add state and zipcode to the address
    // Address Dropdown scrollable
    // Edit address add dropdown
    // Edit Property Type add dropdown
    // Login shake animation when input is invalid
    
    /* BACK LOG */
    // Cache the properties in sql db so I dont have to retrieve them every time the app is opened and closed
    // Potentially remove tab bar and replace with a fan menu
    // Search table view by name
    // Gracefully handle connectivity issues
    
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
        return true
    }
}

