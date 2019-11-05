//
//  Property.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreData

class Property: NSManagedObject {
    var title = ""
    var price = 0
    var squareFootageLiveable = 0
    var propertyType = ""
    var address = ""
    var image = UIImage()
    var createdAt = Date()
    var objectId = ""
    
    // array of properties returned from the query
    var properties = [Property]()
    
    //Empty constructor
    /*convenience override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        self.init(entity: entity, insertInto: context)
        self.title = ""
        self.price = 0
        self.squareFootageLiveable = 0
        self.propertyType = ""
        self.address = ""
        self.image = UIImage()
        self.createdAt = Date()
        self.objectId = ""
    }*/
    
    func getMissingAttributes() -> [String] {
        var missingAttributes = [String]()
        if title == "" {
            missingAttributes.append("Title")
        }
        if price == 0 {
            missingAttributes.append("Price")
        }
        if squareFootageLiveable == 0 {
            missingAttributes.append("Square Footage Liveable")
        }
        if propertyType == "" {
            missingAttributes.append("Property Type")
        }
        if address == "" {
            missingAttributes.append("Address")
        }
        return missingAttributes
    }
    
    func isValid() -> Bool {
        return self.title != "" && self.price != 0 && self.squareFootageLiveable != 0 && self.propertyType != "" && self.address != ""
    }
    
    //Constructor with all params provided
    convenience init(objectId: String, title: String, price: Int, squareFootageLiveable: Int , propertyType: String, address: String, image: UIImage, createdAt: Date) {
        self.init()
        self.title = title
        self.price = price
        self.squareFootageLiveable = squareFootageLiveable
        self.propertyType = propertyType
        self.address = address
        self.image = image
        self.createdAt = createdAt
        self.objectId = objectId
    }
    
    func updateAttribute(attributeType: String, newValue: Any) {
        print(attributeType, newValue)
        let currentProperty = PFObject(withoutDataWithClassName: "Property", objectId: self.objectId)
        currentProperty.setValue(newValue, forKey: attributeType)
        currentProperty.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Success: Updated the property's " + attributeType)
            }
        })
    }
    
    func orderByCreatedAtAscending(properties: [Property]) -> [Property] {
        return properties.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == ComparisonResult.orderedDescending })
    }
    
    func deleteFromParse() {
        PFObject(withoutDataWithClassName: "Property", objectId: self.objectId).deleteInBackground { (success, error) in
            if success {
                print("Success: Deleted the selected property")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func getProperties(query: PFQuery<PFObject>, completion: @escaping (_ result: [Property])->()) {
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    return
                }
                for object in objects! {
                    if let image = object["image"] as? PFFileObject {
                        image.getDataInBackground {
                            (imageData:Data?, error:Error?) -> Void in
                            if error == nil  {
                                if let finalimage = UIImage(data: imageData!) {
                                    let title = object["title"] as! String
                                    print(title)
                                    let price = object["price"] as! Int
                                    let squareFootageLiveable = object["squareFootageLiveable"] as! Int
                                    let propertyType = object["propertyType"] as! String
                                    let address = object["address"] as! String
                                    let createdAt = object.createdAt!
                                    let property = Property(objectId: object.objectId!, title: title, price: price, squareFootageLiveable: squareFootageLiveable, propertyType: propertyType, address: address, image: UIImage(), createdAt: createdAt)
                                    property.image = finalimage
                                    self.properties.append(property)
                                    if self.properties.count == objects?.count {
                                        print(self.properties.count)
                                        completion(self.properties)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
