//
//  PropertyDetailsVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SCLAlertView

class PropertyDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var doneOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var upperShadowLabel: UILabel!
    @IBOutlet weak var lowerShadowLabel: UILabel!
    
    
    
    var selectedProperty = Property()
    var attributeToEdit = ""
    var attributeType = ""
    var fromCreate = false
    
    var tableViewFields = [["Price", "Square footage liveable", "Square footage total"]]
    var attributeNames = [["Price", "Square footage liveable", "Square footage total"]]
    
    var sectionHeaders = ["Details", "Address & Cost", "Size"]
    
    override func viewDidLoad() {
        print("In PropertiesDetailsVC")
        setupUI()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Delete Property") {
            self.selectedProperty.deleteFromParse()
            self.performSegue(withIdentifier: "propertyDeletedUnwind", sender: nil)
        }
        alert.showInfo("Notice", // Title of view
        subTitle: "Are you sure you want to remove this property?", // String of view
        colorStyle: 0x434343,
        colorTextButton: 0xF9E4B7)
        
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.performSegue(withIdentifier: "propertiesUnwind", sender: nil)
    }
    
    
    @IBAction func propertyDetailsUnwind(segue: UIStoryboardSegue) {
        print("Updated", DataModel.newProperty.title)
        setupUI()
    }
    
    func setupUI() {
        
        // defining property
        var property = Property()
        if fromCreate {
            property = DataModel.newProperty
        } else {
            property = selectedProperty
            doneOutlet.isHidden = true
        }
        
        // collection view
        upperShadowLabel.layer.shadowPath = UIBezierPath(rect: upperShadowLabel.bounds).cgPath
        upperShadowLabel.layer.shadowRadius = 3
        upperShadowLabel.layer.shadowOffset = .zero
        upperShadowLabel.layer.shadowOpacity = 0.8
        
        lowerShadowLabel.layer.shadowPath = UIBezierPath(rect: lowerShadowLabel.bounds).cgPath
        lowerShadowLabel.layer.shadowRadius = 3
        lowerShadowLabel.layer.shadowOffset = .zero
        lowerShadowLabel.layer.shadowOpacity = 0.8
        
        // nav bar
        if !(DataModel.adminStatus) || fromCreate {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        // image view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        propertyImageView.isUserInteractionEnabled = true
        propertyImageView.addGestureRecognizer(tapGestureRecognizer)
        self.propertyImageView.image = selectedProperty.image
        propertyImageView.backgroundColor = UIColor.white
        self.propertyImageView.image = property.image
        
        // table view
        tableView.tableFooterView = UIView()
        self.nameLabel.text = property.title
        self.addressLabel.text = property.address
        self.tableViewFields[0][0] = "Price: $" + property.price.withCommas()
        self.tableViewFields[0][1] = "Liveable: " + String(property.squareFootageLiveable.withCommas())
        self.tableViewFields[0][2] = "Total: " + String(property.squareFootageTotal.withCommas())
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        imageViewSelected()
    }
    
    func imageViewSelected() {
        print("trying to add image")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        let messageAttrString = NSMutableAttributedString(string: "Choose Image", attributes: nil)
        
        alert.setValue(messageAttrString, forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Default", style: .default, handler: { _ in
            self.propertyImageView.image = UIImage(named: "cityBackground")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if fromCreate {
                DataModel.newProperty.image = img
            } else {
                self.selectedProperty.image = img
                if let imageData = img.jpegData(compressionQuality: 0.25) {
                    let file = PFFileObject(name: "img.png", data: imageData)
                    selectedProperty.updateAttribute(attributeType: "image", newValue: file!)
                    selectedProperty.image = img
                    DataModel.propertyImageChanged = true
                }
            }
            propertyImageView.image = img
        } else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if fromCreate {
                DataModel.newProperty.image = img
            } else {
                self.selectedProperty.image = img
                if let imageData = img.jpegData(compressionQuality: 0.25) {
                    let file = PFFileObject(name: "img.png", data: imageData)
                    selectedProperty.updateAttribute(attributeType: "image", newValue: file!)
                }
            }
            propertyImageView.image = img
        }
        dismiss(animated:true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DataModel.adminStatus {
            self.attributeToEdit = tableViewFields[indexPath.section][indexPath.row]
            self.attributeType = self.attributeNames[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "showEditAttribute", sender: nil)
        }
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
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewCell()
        header.textLabel!.text = sectionHeaders[section]
        header.backgroundColor = #colorLiteral(red: 0.9073890448, green: 0.8150985837, blue: 0.6634473205, alpha: 1)
        header.textLabel?.textColor = UIColor.darkGray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        return header
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditAttribute" {
            let targetVC = segue.destination as! EditPropertyAttributeVC
            targetVC.attributeToEdit = self.attributeToEdit
            targetVC.fromCreate = self.fromCreate
            print(self.attributeToEdit)
            targetVC.originalValue = self.attributeToEdit
            targetVC.attributeType = self.attributeType
            targetVC.selectedProperty = self.selectedProperty
            print("Segue: PropertiesVC -> PropertyDetailsVC")
        } else if segue.identifier == "propertyDeletedUnwind" {
            
        }
    }
}
