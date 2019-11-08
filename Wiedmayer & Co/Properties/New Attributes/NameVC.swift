//
//  NameVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NameVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Property", in: context)
        let newProperty = NSManagedObject(entity: entity!, insertInto: context) as! Property
        DataModel.newProperty = newProperty
        textField.delegate = self
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            //DataModel.newProperty.title = text
            DataModel.newProperty.setValue(text, forKey: "title")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
          self.textField.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
