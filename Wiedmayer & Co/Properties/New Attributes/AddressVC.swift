//
//  AddressVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/13/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import DropDown
import MapKit

class AddressVC: UIViewController, UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    let dropDown = DropDown()
    var addresses = [""]
    var searchResults = [MKLocalSearchCompletion]()
    var searchCompleter = MKLocalSearchCompleter()
    
    override func viewDidLoad() {
        textField.delegate = self
        self.textField.addTarget(self, action: #selector(NameVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        print(DataModel.newProperty.title)
    }
    
    func setupDropDown() {
        searchCompleter.delegate = self
        
        dropDown.anchorView = self.textField
        //dropDown.bottomOffset = CGPoint(x: 0, y: 10)
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = addresses
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textField.text = item
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        addresses.removeAll()
        for i in 0..<3 {
            if i < completer.results.count {
                addresses.append(completer.results[i].title)
            }
        }
        dropDown.dataSource = addresses
        dropDown.show()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            DataModel.newProperty.address = text
            searchCompleter.queryFragment = text
        }
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
