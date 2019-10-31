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
import WLEmptyState
import SkeletonView

class PropertiesVC: UITableViewController, WLEmptyStateDataSource, UISearchResultsUpdating {
    
    var selectedProperty = Property()
    var properties = [Property]()
    var filteredProperties = [Property]()
    var resultSearchController = UISearchController()

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
            NewProperty["propertyType"] = DataModel.newProperty.propertyType
            
            
            if let imageData = DataModel.newProperty.image.jpegData(compressionQuality: 0.25) {
                let file = PFFileObject(name: "img.png", data: imageData)
                NewProperty["image"] = file
            }
            
            NewProperty.saveInBackground { (success, error) in
                if success {
                    print("Success: New Property Saved")
                    print(NewProperty.objectId!)
                    DataModel.newProperty.objectId = NewProperty.objectId!
                    // Reset the newProperty to empty
                    if self.properties.count == 0 {
                        self.properties.append(DataModel.newProperty)
                    } else if self.properties.count > 0 {
                        self.properties.insert(DataModel.newProperty, at: 0)
                    }
                    self.tableView.reloadData()
                    DataModel.newProperty = Property()
                } else {
                    print("--NETWORK ERROR?--")
                    print(error?.localizedDescription)
                }
            }
        } else if segue.identifier == "propertyDeletedUnwind" {
            // delete property from the tableview
            properties.removeAll{$0 === self.selectedProperty}
            tableView.reloadData()
            self.selectedProperty = Property()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DataModel.propertyImageChanged {
            DataModel.propertyImageChanged = false
            self.tableView.reloadData()
        }
        if DataModel.propertyAttributeChanged {
            DataModel.propertyAttributeChanged = true
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        print("In PropertiesVC")
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = true
        self.properties = DataModel.properties
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        if self.properties.count == 0 { // Show empty set
            self.tableView.emptyStateDataSource = self
            self.tableView.reloadData()
        }
    }
    
    func setupUI() {
        
        
        self.resultSearchController.searchBar.autocapitalizationType = .words
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        /*resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            controller.searchBar.barTintColor = UIColor.darkGray
            controller.searchBar.searchTextField.backgroundColor = UIColor(red: 225/255, green: 198/255, blue: 153/255, alpha: 1)
            return controller
        })()*/
        
        self.tableView.showsVerticalScrollIndicator = false
        if !(DataModel.adminStatus) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func queryProperties() {
        let query = PFQuery(className: "Property")
        query.addDescendingOrder("createdAt")
        query.limit = 100
        let propertyRef = Property()
        propertyRef.getProperties(query: query, completion: { (propertyObjects) in
            self.properties = propertyRef.orderByCreatedAtAscending(properties: propertyObjects)
            self.tableView.reloadData()
            self.tableView.tableFooterView = UIView()
            if self.properties.count == 0 { // Show empty set
                self.tableView.emptyStateDataSource = self
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var propertiesToShow = [Property]()
        if (resultSearchController.isActive) {
            propertiesToShow = filteredProperties
        } else {
            propertiesToShow = self.properties
        }
        return propertiesToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var propertiesToShow = [Property]()
        if (resultSearchController.isActive) {
            propertiesToShow = filteredProperties
        } else {
            propertiesToShow = self.properties
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell") as! PropertyTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel?.text = propertiesToShow[indexPath.row].title
        cell.propertyImageView.image = propertiesToShow[indexPath.row].image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var propertiesToShow = [Property]()
        if (resultSearchController.isActive) {
            propertiesToShow = filteredProperties
        } else {
            propertiesToShow = self.properties
        }
        self.selectedProperty = propertiesToShow[indexPath.row]
        self.performSegue(withIdentifier: "showPropertyDetails", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return screenWidth
    }
    
    func imageForEmptyDataSet() -> UIImage? {
        return UIImage(named: "emptySet")
    }
    
    func titleForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "No Properties Found", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
        return title
    }
    
    func descriptionForEmptyDataSet() -> NSAttributedString {
        let title = NSAttributedString(string: "Click on the \"+\" button to create a new property.", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        return title
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredProperties = self.properties.filter {
            $0.title.range(of: searchController.searchBar.text!, options: .caseInsensitive) != nil
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPropertyDetails" {
            let targetVC = segue.destination as! PropertyDetailsVC
            targetVC.selectedProperty = self.selectedProperty
            print("Segue: PropertiesVC -> PropertyDetailsVC")
        }
    }
}
