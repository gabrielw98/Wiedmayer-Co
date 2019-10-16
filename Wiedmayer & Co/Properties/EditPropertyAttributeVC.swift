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
                if self.attributeType == "Title" {
                    DataModel.newProperty.title = self.textField.text!
                } else if self.attributeType == "Address" {
                    DataModel.newProperty.address = self.textField.text!
                } else if self.attributeType == "Price" {
                    //TODO change keyboard types
                    DataModel.newProperty.price = Int(self.textField.text!)!
                } else if self.attributeType == "Square footage liveable" {
                    DataModel.newProperty.squareFootageLiveable = Int(self.textField.text!)!
                } else if self.attributeType == "Square footage total" {
                    DataModel.newProperty.squareFootageTotal = Int(self.textField.text!)!
                }
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
