//
//  Property+CoreDataClass.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 11/4/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//
//

import Foundation
import UIKit
import Parse
import CoreData


public class Property: NSManagedObject {
    
    var image = UIImage()
    
    // array of properties returned from the query
    var properties = [Property]()
    
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
        self.price = Int64(price)
        self.squareFootageLiveable = Int64(squareFootageLiveable)
        self.propertyType = propertyType
        self.address = address
        self.imageData = image.pngData()
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
        return properties.sorted(by: { $0.createdAt!.compare($1.createdAt as! Date) == ComparisonResult.orderedDescending })
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
    
    func savePropertyToCoreData(objectId: String, address: String, title: String, price: Int64, squareFootageLiveable: Int64, propertyType: String, imageData: Data, createdAt: Date, image: UIImage) -> Property {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Property", in: context)
        let newProperty = NSManagedObject(entity: entity!, insertInto: context) as! Property
        newProperty.objectId = objectId
        newProperty.address = address
        newProperty.title = title
        newProperty.price = price
        newProperty.squareFootageLiveable = squareFootageLiveable
        newProperty.propertyType = propertyType
        newProperty.imageData = imageData
        newProperty.createdAt = createdAt
        newProperty.image = image
        
        /*do {
           try context.save()
          } catch {
           print("Error: Failed Saving Property To Core Data")
        }*/
        return newProperty
    }
    
    func deletePropertiesFromCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = CoreDataManager.shared.persistentContainer.viewContext

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print("Error:", error)
        }
    }
    
    func fetchPropertiesFromCoreData() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            print(result.count)
            for data in result as! [NSManagedObject] {
                print("Fetched...")
                print(data.value(forKey: "title") as! String)
          }
        } catch {
            print("Failed")
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
                                    let price = Int64(object["price"] as! Int)
                                    let squareFootageLiveable = Int64(object["squareFootageLiveable"] as! Int)
                                    let propertyType = object["propertyType"] as! String
                                    let address = object["address"] as! String
                                    let createdAt = object.createdAt!
                                    
                                    let property = self.savePropertyToCoreData(objectId: object.objectId!, address: address, title: title, price: price, squareFootageLiveable: squareFootageLiveable, propertyType: propertyType, imageData: imageData!, createdAt: createdAt, image: finalimage)
                                    
                                    //property.imageData = finalimage.pngData()
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
