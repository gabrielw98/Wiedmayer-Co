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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBAction func confirmAction(_ sender: Any) {
        if textField.text != nil {
            if textField.text!.isEmpty {
                let emptyTextFieldAlert = UIAlertController(title: "Notice", message: "You must enter a new " + self.attributeType, preferredStyle: UIAlertController.Style.alert)
                emptyTextFieldAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                    print("should not see this")
                    return
                }))
                self.present(emptyTextFieldAlert, animated: true)
                emptyTextFieldAlert.view.tintColor = UIColor.darkGray
            }
            
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to change (" + self.originalValue + ") to (" + self.textField.text! + ")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                var propertyToEdit = Property()
                if self.fromCreate {
                    propertyToEdit = DataModel.newProperty
                } else {
                    propertyToEdit = self.selectedProperty
                }
                var attributeToChangeKey = ""
                var newValue = Any?(self.textField.text!)
                
                if self.attributeType == "Title" {
                    propertyToEdit.title = self.textField.text!
                    attributeToChangeKey = "title"
                    
                } else if self.attributeType == "Address" {
                    propertyToEdit.address = self.textField.text!
                    attributeToChangeKey = "address"
                } else if self.attributeType == "Price" {
                    //TODO change keyboard types
                    propertyToEdit.price = Int(self.textField.text!)!
                    attributeToChangeKey = "price"
                    newValue = Int(self.textField.text!)!
                } else if self.attributeType == "Square footage liveable" {
                    propertyToEdit.squareFootageLiveable = Int(self.textField.text!)!
                    attributeToChangeKey = "squareFootageLiveable"
                    newValue = Int(self.textField.text!)!
                } else if self.attributeType == "Property Type" {
                    propertyToEdit.propertyType = self.textField.text!
                    attributeToChangeKey = "propertyType"
                    newValue = self.textField.text
                }
                
                propertyToEdit.updateAttribute(attributeType: attributeToChangeKey, newValue: newValue!)
                // TODO Update property field in backend
                // use the property class to handle this backend code
                DataModel.propertyAttributeChanged = true
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
        if self.attributeType == "Square footage total" || self.attributeType == "Square footage liveable"
            || self.attributeType == "Price" {
            self.textField.keyboardType = .numberPad
        } else if self.attributeType == "Title" {
            self.textField.autocapitalizationType = .words
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        self.textField.placeholder = self.attributeToEdit + "..."
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
       let keyboardHeight = keyboardSize?.height
       if #available(iOS 11.0, *) {
            self.bottomConstraint.constant = -(keyboardHeight!)
       } else {
            
             self.bottomConstraint.constant = -keyboardHeight!
           }
        self.bottomConstraint.constant = keyboardHeight!

        
        UIView.animate(withDuration: 1.5) {
            self.bottomConstraint.constant = -keyboardHeight!
         }
     }

    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 0 // or change according to your logic
         UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
         }
    }

}
