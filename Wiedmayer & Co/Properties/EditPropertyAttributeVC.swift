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
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to change the this property's " + self.attributeToEdit + " from to " + self.textField.text!, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    var attributeToEdit = ""
    
    override func viewDidLoad() {
        print("In EditPropertyAttributeVC")
        setupUI()
    }
    
    func setupUI() {
        self.hideKeyboardWhenTappedAround()
        self.textField.placeholder = "Updating " + self.attributeToEdit + "..."
    }
    
    
    
    
}
