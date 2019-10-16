//
//  PropertyDetailsVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class PropertyDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var doneOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedProperty = Property()
    var attributeToEdit = ""
    var attributeType = ""
    var fromCreate = false
    
    var tableViewFields = [["Title"], ["Address", "Price"], ["Square footage liveable", "Square footage total"]]
    var attributeNames = [["Title"], ["Address", "Price"], ["Square footage liveable", "Square footage total"]]
    
    override func viewDidLoad() {
        print("In PropertiesDetailsVC")
        setupUI()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.performSegue(withIdentifier: "propertiesUnwind", sender: nil)
        
    }
    
    
    @IBAction func propertyDetailsUnwind(segue: UIStoryboardSegue) {
        print("Updated", DataModel.newProperty.title)
        setupUI()
    }
    
    func setupUI() {
        self.propertyImageView.image = selectedProperty.image
        tableView.tableFooterView = UIView()
        if !fromCreate {
            self.title = String(selectedProperty.title)
            doneOutlet.isHidden = true
        } else {
            self.title = DataModel.newProperty.title
            print("New Property Attributes:")
            print(DataModel.newProperty.title)
            print(DataModel.newProperty.address)
            print(DataModel.newProperty.price)
            print(DataModel.newProperty.squareFootageLiveable)
            print(DataModel.newProperty.squareFootageTotal)
            
            self.tableViewFields[0][0] = DataModel.newProperty.title
            
            self.tableViewFields[1][0] = DataModel.newProperty.address
            self.tableViewFields[1][1] = String(DataModel.newProperty.price)
            
            self.tableViewFields[2][0] = String(DataModel.newProperty.squareFootageLiveable)
            self.tableViewFields[2][1] = String(DataModel.newProperty.squareFootageTotal)
            
            self.propertyImageView.image = DataModel.newProperty.image
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.attributeToEdit = tableViewFields[indexPath.section][indexPath.row]
        self.attributeType = self.attributeNames[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "showEditAttribute", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.selectionStyle = .none
        cell.textLabel?.textColor = UIColor.darkGray
        if fromCreate {
            cell.textLabel?.text = tableViewFields[indexPath.section][indexPath.row]
        } else {
            cell.textLabel?.text = tableViewFields[indexPath.section][indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewFields[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewFields.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditAttribute" {
            let targetVC = segue.destination as! EditPropertyAttributeVC
            targetVC.attributeToEdit = self.attributeToEdit
            targetVC.fromCreate = self.fromCreate
            print(self.attributeToEdit)
            targetVC.originalValue = self.attributeToEdit
            targetVC.attributeType = self.attributeType
            print("Segue: PropertiesVC -> PropertyDetailsVC")
        }
    }
}
