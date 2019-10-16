//
//  SquareFootageLiveable.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class SquareFootageLiveableVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                DataModel.newProperty.squareFootageLiveable = 0
            } else {
                DataModel.newProperty.squareFootageLiveable = Int(text)!
            }
        }
    }
}
