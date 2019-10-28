//
//  SquareFootageLiveable.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import DropDown

class PropertyTypeVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
        
    let dropDown = DropDown()
    var propertyTypes = ["Industrial", "Office", "Retail", "Land", "Special Purpose"]
    
    override func viewDidLoad() {
        textField.delegate = self
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty {
                DataModel.newProperty.propertyType = ""
            } else {
                DataModel.newProperty.propertyType = text
            }
            var filteredProperties = [String]()
            for type in propertyTypes {
                if (type.lowercased().contains(String(textField.text!)) || type.contains(String(textField.text!)))  && filteredProperties.count < 2 {
                    filteredProperties.append(type)
                }
            }
            dropDown.dataSource = filteredProperties
            dropDown.show()
        }
    }
    
    func setupDropDown() {
        dropDown.anchorView = self.textField
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = propertyTypes
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textField.text = item
        }
        let filteredProperties = [propertyTypes[0], propertyTypes[1]]
        dropDown.dataSource = filteredProperties
        dropDown.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
          self.textField.becomeFirstResponder()
            self.setupDropDown()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
