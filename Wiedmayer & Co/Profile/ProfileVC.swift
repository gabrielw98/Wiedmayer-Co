//
//  ProfileVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ProfileVC: UITableViewController {
    
    
    @IBAction func logOutAction(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Notice", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action: UIAlertAction!) in
            PFUser.logOut()
            print("logging out")
            self.performSegue(withIdentifier: "unwindProfileToRegistration", sender: nil)
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        print("In ProfileVC")
    }
    
    
}
