//
//  EditPropertyAttributeVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class EditPropertyAttributeVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBAction func confirmAction(_ sender: Any) {
        
        if textField.text != nil {
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to change (" + self.originalValue + ") to (" + self.textField.text! + ")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                var propertyToEdit = Property()
                if self.fromCreate {
                    propertyToEdit = DataModel.newProperty
                } else {
                    propertyToEdit = self.selectedProperty
                }
                if self.attributeType == "Title" {
                    propertyToEdit.title = self.textField.text!
                } else if self.attributeType == "Address" {
                    propertyToEdit.address = self.textField.text!
                } else if self.attributeType == "Price" {
                    //TODO change keyboard types
                    propertyToEdit.price = Int(self.textField.text!)!
                } else if self.attributeType == "Square footage liveable" {
                    propertyToEdit.squareFootageLiveable = Int(self.textField.text!)!
                } else if self.attributeType == "Square footage total" {
                    propertyToEdit.squareFootageTotal = Int(self.textField.text!)!
                }
                
                // TODO Update property field in backend
                // use the property class to handle this backend code
                
                self.performSegue(withIdentifier: "propertyDetailsUnwind", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            alert.view.tintColor = UIColor.darkGray
        }
    }
    
    var originalValue = ""
    var attributeToEdit = ""
    var attributeType = ""
    var fromCreate = false
    var selectedProperty = Property()
    
    override func viewDidLoad() {
        print("In EditPropertyAttributeVC")
        print("original value", originalValue)
        setupUI()
    }
    
    func setupUI() {
        self.hideKeyboardWhenTappedAround()
        self.textField.placeholder = self.attributeToEdit + "..."
    }

}
