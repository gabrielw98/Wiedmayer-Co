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
import CoreData

class PropertiesVC: UITableViewController, WLEmptyStateDataSource, UISearchResultsUpdating {
    
    var selectedProperty = Property()
    var properties = [Property]()
    var filteredProperties = [Property]()
    let searchController = UISearchController(searchResultsController: nil)
    var newPropertyButton = UIBarButtonItem()
    
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
            
            if let imageData = DataModel.newProperty.image.jpegData(compressionQuality: 1.00) {
                let file = PFFileObject(name: "img.png", data: imageData)
                NewProperty["image"] = file
            }
            
            NewProperty.saveInBackground { (success, error) in
                if success {
                    print("Success: New Property Saved")
                    print(NewProperty.objectId!)
                    DataModel.newProperty.objectId = NewProperty.objectId!
                    
                    if self.properties.count == 0 {
                        self.properties.append(DataModel.newProperty)
                    } else if self.properties.count > 0 {
                        print("Properties count before", self.properties.count)
                        self.properties.insert(DataModel.newProperty, at: 0)
                        print("Properties count after", self.properties.count)
                    }
                    self.tableView.reloadData()
                    
                    // Reset the newProperty to empty
                    DataModel.newProperty = Property()
                } else {
                    print("--NETWORK ERROR?--")
                    print(error?.localizedDescription)
                }
            }
        } else if segue.identifier == "propertyDeletedUnwind" {
            // delete property from the tableview
            print("in property delete unwind")
            print(self.properties.count)
            DataModel.properties.removeAll{$0 === self.selectedProperty}
            print(self.properties.count)
            self.tableView.reloadData()
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
        
        if DataModel.adminStatusChanged {
            DataModel.adminStatusChanged = false
            print(DataModel.adminStatus, "status")
            self.navigationItem.rightBarButtonItem = newPropertyButton
        }
    }
    
    override func viewDidLoad() {
        print("In PropertiesVC")
        setupUI()
        //createPropertyTest()
    }
    
    func createPropertyTest() {
        
        //let managedObjectContext = CoreDataManager.shared.context
        //let entity = NSEntityDescription.entity(forEntityName: "Property", in: managedObjectContext)
        
        /*print(entity == nil)
        print(managedObjectContext == nil)
        let newProperty = Property(entity: entity!, insertInto: managedObjectContext)
        CoreDataManager.shared.save()*/
        
    }
    
    func getProperty() {
        guard let properties = try! CoreDataManager.shared.context.fetch(NSFetchRequest<Property>(entityName: "Property")) as? [Property] else { return }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = true
        self.properties = DataModel.properties
        self.properties = Property().orderByCreatedAtAscending(properties: properties)
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        if self.properties.count == 0 { // Show empty set
            self.tableView.emptyStateDataSource = self
            self.tableView.reloadData()
        }
    }
    
    func setupUI() {
        
        // Refresh Controller
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 225/255, green: 198/255, blue: 153/255, alpha: 1)]
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Searching for new properties...", attributes: attributes)
        self.refreshControl?.tintColor = UIColor(red: 249/255, green: 228/255, blue: 183/255, alpha: 1)
        self.refreshControl?.addTarget(self, action: #selector(startRefresh), for: UIControl.Event.valueChanged)
        
        // Search Controller
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.backgroundColor = UIColor.lightText
        searchController.searchBar.autocapitalizationType = .words
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        
        // Table View
        self.tableView.backgroundColor = UIColor.gray
        self.tableView.showsVerticalScrollIndicator = false
       
        // Admin Status
        if !(DataModel.adminStatus == "Verified") {
            newPropertyButton = self.navigationItem.rightBarButtonItem!
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
    
    func queryNewProperties(timestamp: Date) {
        let query = PFQuery(className: "Property")
        query.addDescendingOrder("createdAt")
        query.whereKey("createdAt", greaterThan: timestamp)
        query.limit = 100
        let propertyRef = Property()
        propertyRef.getProperties(query: query, completion: { (propertyObjects) in
            print("PARSE OBJECTS:", propertyObjects.count)
            for property in propertyObjects {
                self.properties.insert(property, at: 0)
                self.tableView.reloadData()
            }
            //DataModel.properties.insert(contentsOf: propertyRef.orderByCreatedAtAscending(properties: propertyObjects), at: 0)
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var propertiesToShow = [Property]()
        if (searchController.isActive) {
            propertiesToShow = filteredProperties
        } else {
            propertiesToShow = self.properties
        }
        return propertiesToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var propertiesToShow = [Property]()
        print("properties count", self.properties.count)
        if (searchController.isActive) {
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
        if (searchController.isActive) {
            propertiesToShow = filteredProperties
        } else {
            propertiesToShow = self.properties
        }
        propertiesToShow = Property().orderByCreatedAtAscending(properties: propertiesToShow)
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
        if searchController.searchBar.text!.isEmpty {
            self.filteredProperties = properties
            self.tableView.reloadData()
            return
        }
        self.filteredProperties = self.properties.filter {
            $0.title!.range(of: searchController.searchBar.text!, options: .caseInsensitive) != nil
        }
        self.tableView.reloadData()
    }
    
    @objc func startRefresh(sender:AnyObject) {
        // First check core data
        print("Refreshing...")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
        let userRef = User()
        let propertyRef = Property()
        let lastQuery = userRef.fetchLastQueryTimestamp()
        queryNewProperties(timestamp: lastQuery)
        self.properties = Property().orderByCreatedAtAscending(properties: properties)
        self.tableView.reloadData()
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    @objc func endRefresh() {
        print("End Refreshing...")
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPropertyDetails" {
            let targetVC = segue.destination as! PropertyDetailsVC
            targetVC.selectedProperty = self.selectedProperty
            print("Segue: PropertiesVC -> PropertyDetailsVC")
        }
    }
}
