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
        // Update core data Property
        self.updatePropertyInCoreData(objectId: self.objectId!, attributeType: attributeType, newValue: newValue)
        print("break from function")
        let currentProperty = PFObject(withoutDataWithClassName: "Property", objectId: self.objectId)
        currentProperty.setValue(newValue, forKey: attributeType)
        currentProperty.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Success: Updated the property's " + attributeType)
            }
        })
    }
    
    func orderByCreatedAtAscending(properties: [Property]) -> [Property] {
        return properties.sorted(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
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
    
    func updatePropertyInCoreData(objectId: String, attributeType: String, newValue: Any) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
        do {
            let result = try context.fetch(fetchRequest)
            if result.count == 1 {
                let propertyToUpdate = result[0] as! Property
                print(propertyToUpdate)
                propertyToUpdate.setValue(newValue, forKey: attributeType)
                
                print("updated in core data")
            } else {
                print("Error: Incorrect result count... Could not update", result.count, "Properties")
            }
            
            do {
                try context.save()
               }
            catch {
                print("Saving Core Data Failed: \(error)")
            }
        } catch {
            print("Error: Failed to update")
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
    
    func fetchPropertiesFromCoreData() -> [Property] {
        var fetchedProperties = [Property]()
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            print("FETCHED CORE DATA", result.count)
            for property in result as! [Property] {
                print("Fetched...")
                print(property.title)
                property.image = UIImage(data: property.imageData!)!
                fetchedProperties.append(property)
            }
            fetchedProperties = result as! [Property]
            return fetchedProperties
        } catch {
            print("Failed")
        }
        return fetchedProperties
    }
    
    func getProperties(query: PFQuery<PFObject>, completion: @escaping (_ result: [Property])->()) {
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    print("No new objects")
                    completion(self.properties)
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
                                        let userRef = User()
                                        userRef.updateLastQuery()
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
