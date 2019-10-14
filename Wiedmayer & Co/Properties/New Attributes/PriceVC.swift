//
//  PriceVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class PriceVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            //TODO - app crashes when user types decimal point twice
            //Fix just make it take Int
            DataModel.newProperty.price = Double(text)!
        }
    }
    
}
