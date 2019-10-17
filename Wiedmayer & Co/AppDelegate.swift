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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Properties deletion
    // Properties update db
    
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

