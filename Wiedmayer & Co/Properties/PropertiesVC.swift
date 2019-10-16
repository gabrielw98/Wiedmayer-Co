//
//  Properties.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class PropertiesVC: UITableViewController {
    
    var selectedProperty = Property()
    var properties = [Property]()

    @IBAction func createPropertyAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showCreateAttributes", sender: nil)
    }
    
    @IBAction func propertiesUnwind(segue: UIStoryboardSegue) {
        if segue.identifier == "propertiesUnwind" {
            print("Success: Done Unwind")
            let NewProperty = PFObject(className: "Property")
            NewProperty["title"] = DataModel.newProperty.title
            NewProperty["address"] = DataModel.newProperty.address
            NewProperty["price"] = DataModel.newProperty.price
            NewProperty["squareFootageLiveable"] = DataModel.newProperty.squareFootageLiveable
            NewProperty["squareFootageTotal"] = DataModel.newProperty.squareFootageTotal
            if let imageData = DataModel.newProperty.image.jpegData(compressionQuality: 0.25) {
                let file = PFFileObject(name: "img.png", data: imageData)
                NewProperty["image"] = file
            }
            NewProperty.saveInBackground { (success, error) in
                if success {
                    print("Property Saved")
                }
            }
            // Reset the newProperty to empty
            DataModel.newProperty = Property()
        }
    }
    
    override func viewDidLoad() {
        print("In PropertiesVC")
        self.properties = Property().getProperties()
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = self.properties[indexPath.row].title
        cell.imageView?.image = self.properties[indexPath.row].image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedProperty = self.properties[indexPath.row]
        self.performSegue(withIdentifier: "showPropertyDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPropertyDetails" {
            let targetVC = segue.destination as! PropertyDetailsVC
            targetVC.selectedProperty = self.selectedProperty
            print("Segue: PropertiesVC -> PropertyDetailsVC")
        }
    }
    
    

}
