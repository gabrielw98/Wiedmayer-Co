//
//  AddressVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class AddressVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        print("AddressVC")
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        print(DataModel.newProperty.title)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            DataModel.newProperty.address = text
        }
    }
    
}
