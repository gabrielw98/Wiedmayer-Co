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
import Reachability
import SCLAlertView
import CoreData

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
    //*Gracefully handle connectivity issues
    //*Move search bar into navigation bar FB style
    //*Search table view by name
    //*Test each stage of admin verification process
    //*Core Data Fetch
    //*Core data
    //*Add an image and description behind the table view when there is no data
    
    /* MAIN PRIORITIES */
    //1 Update core data with deleted info
    //2 Update core data with updated using updatedAt time stamp
    //3 Constraints for all devices
    
    /* IN PROGRESS */
    // Update fetch properties from core data to take in deleted ids and
    // Constraints for all devices
    // Deleted & updated markers -- Replace query createdAt timestamp with
    // Query objects where updated at does not exist in the current list
    // Deletion can use DeletedProperties -- check in view did load
    // Send push on deletion
    // Add push capabilities from back4app dashboard
    // Change tableView background of properties to be a gray gradient
    
    /* BACK LOG */
    // Cloud code main.js updates deleted & updated
    // Create property image constraints
    // Address Dropdown scrollable
    // Remove Search Nearby from address suggestions
    // Edit Property Type add dropdown
    // Refactor AppDelegate query and setup admin to launch vc
    // Add Skeleton View
    // Force square images or exapnd to fill square
    
    // Core Data Story
    // When the user opens the app, check core data for user in core data
    // If user does NOT exist, query all properties then save new user with current timestamp
    // If user exists, check time stamp, pull Properties createdAt later than timestamp (if any), fetch properties already in  core data. Save new properties to core data. Show new properties + fetched properties.
    
    // when recieved parse objects, update time stamp
    // reset timestamp
    // query properties
    // image data is not being saved to core data new property is created
    
    var window: UIWindow?
    let reachability = try! Reachability()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
          try reachability.startNotifier()
        } catch {
          print("could not start reachability notifier")
        }
        
        
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
        
        let userRef = User()
        let lastQuery = userRef.fetchLastQueryTimestamp()
        print("Last Query:", lastQuery)
        
        //userRef.deleteUserFromCoreData()
        //Property().deletePropertiesFromCoreData()
        
        if (userRef.isNewUser()) {
            print("New User Querying")
            queryNewProperties(timestamp: lastQuery)
            let _ = userRef.saveUserToCoreData()
        } else {
            print("Existing User Querying")
            // Perhaps just send a push and maybe there is logic that handles deletion even if push isnt opened
            let propertyRef = Property()
            propertyRef.getDeletedProperties(completion: { (deletedIds) in
                print("deleted property ids:", deletedIds)
                let fetchedProperties = propertyRef.fetchPropertiesFromCoreData(deletedPropertyIds: deletedIds)
                DataModel.properties = fetchedProperties
                self.queryNewProperties(timestamp: lastQuery)
            })
        }
        return true
    }
    
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?

        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)

        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }

        return result
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
            case .wifi:
                print("Reachable via WiFi")
            case .cellular:
                print("Reachable via Cellular")
            case .unavailable:
              print("Network not reachable")
              let alertViewIcon = UIImage(named: "noWifi")
              let appearance = SCLAlertView.SCLAppearance(kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!, kTextFont: UIFont(name: "HelveticaNeue", size: 14)!, kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!, showCloseButton: true)
              let alert = SCLAlertView(appearance: appearance)
              alert.showInfo("Notice", subTitle: "You must connect to a wifi network", closeButtonTitle: "Done", timeout: .none, colorStyle: 0x434343, colorTextButton: 0xF9E4B7, circleIconImage: alertViewIcon, animationStyle: .topToBottom)
            case .none:
              print("none case")
        }
    }
    
    func setupAdminStatus() {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground { (object, error) in
            if (error != nil) {
                print("CAPTURED NETWORK ERROR")
            }
            if object != nil {
                if let isAdmin = object!["isAdmin"] {
                    DataModel.isAdmin = isAdmin as! Bool
                }
                if let adminStatus = object!["adminStatus"] {
                    DataModel.adminStatus = adminStatus as! String
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func queryNewProperties(timestamp: Date) {
        print("QUERYING NEW PROPERTIES")
        let updatedAtRef = UpdatedAt()
        //updatedAtRef.deleteAllTimestamps()
        let updatedAtList = updatedAtRef.fetchUpdatedAtTimestamps()
        print("updated at list ", updatedAtList)
        
        let query = PFQuery(className: "Property")
        query.addDescendingOrder("createdAt")
        //query.whereKey("createdAt", greaterThan: timestamp)
        query.whereKey("updatedAt", notContainedIn: updatedAtList)
        query.limit = 100
        let propertyRef = Property()
        propertyRef.getProperties(query: query, completion: { (propertyObjects) in
            print("PARSE OBJECTS:", propertyObjects.count)
            DataModel.properties.insert(contentsOf: propertyRef.orderByCreatedAtAscending(properties: propertyObjects), at: 0)
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

