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
        print("old time stamp", currentProperty.updatedAt)
        if attributeType == "image" {
            let imageData = newValue as! Data
            currentProperty[attributeType] = PFFileObject(name: "img.png", data: imageData)
        } else {
            currentProperty[attributeType] = newValue
        }
        
        currentProperty.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Success: Updated the property's " + attributeType)
                print("new time stamp.")
                UpdatedAt().updateTimestamp(objectId: currentProperty.objectId!, timestamp: currentProperty.updatedAt!)
            }
        })
    }
    
    func orderByCreatedAtAscending(properties: [Property]) -> [Property] {
        return properties.sorted(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
    }
    
    func deleteFromParse() {
        var objectIdTemp = self.objectId
        print("trying to delete from parse", self.objectId)
        self.deletePropertyFromCoreData(objectId: self.objectId!)
        PFObject(withoutDataWithClassName: "Property", objectId: self.objectId).deleteInBackground { (success, error) in
            if success {
                print("Success: Deleted the selected property")
                
                
                // Figure out how to best track updates and deletes
                let query = PFQuery(className:"UpdatedProperties")
                query.whereKey("updateType", equalTo: "delete")
                query.getFirstObjectInBackground { (deletedObject: PFObject?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let deletedObject = deletedObject {
                        deletedObject.addUniqueObject(objectIdTemp, forKey: "propertyIds")
                        deletedObject.saveInBackground()
                        print("Success: Saved delete object id")
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func deletePropertyFromCoreData(objectId: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            print("Deleted from core data")
        } catch {
            // Error Handling
            print("Deleting Core Data Failed: \(error)")
        }
    }
    
    func updatePropertyInCoreData(objectId: String, attributeType: String, newValue: Any) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if attributeType == "image" {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
            request.predicate = NSPredicate(format: "objectId = %@", objectId)
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                if result.count == 1, let property = result[0] as? NSManagedObject {
                    property.setValue(newValue, forKey: "imageData")
                    try context.save()
                    //fetchPropertiesFromCoreData()
                }
            } catch {
                print("Error: Failed to fetch user")
            }
        } else {
            let request = NSBatchUpdateRequest(entityName: "Property")
            request.predicate = NSPredicate(format: "objectId = %@", objectId)
            request.propertiesToUpdate = [attributeType: newValue]
            do {
                try context.execute(request)
                //fetchPropertiesFromCoreData()
            } catch {
                // Error Handling
                print("Updating in Core Data Failed: \(error)")
            }
        }
    }
    
    func savePropertyToCoreData(objectId: String, address: String, title: String, price: Int64, squareFootageLiveable: Int64, propertyType: String, imageData: Data, createdAt: Date, updatedAt: Date, image: UIImage) -> Property {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Property", in: context)
        let coreDataIds = DataModel.properties.map { $0.objectId! }
        print("core data ids", coreDataIds)
        
        if coreDataIds.contains(objectId) {
            // Delete the property because we can't keep track of all the updates
            if let index = DataModel.properties.index(where: { $0.objectId == objectId }) {
                // removing item
                DataModel.properties.remove(at: index)
            }
            self.deletePropertyFromCoreData(objectId: objectId)
            UpdatedAt().updateTimestamp(objectId: objectId, timestamp: updatedAt)
        }
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
        newProperty.updatedAt = updatedAt
        
        do {
            if true {
                try context.save()
            } else {
                
            }
            //fetchPropertiesFromCoreData()
          } catch {
            print("Error: Failed Saving Property To Core Data")
        }
        return newProperty
    }
    
    func deletePropertiesFromCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = CoreDataManager.shared.persistentContainer.viewContext

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error:", error)
        }
    }
    
    func fetchPropertiesFromCoreData(deletedPropertyIds: [String]) -> [Property] {
        var fetchedProperties = [Property]()
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        request.returnsObjectsAsFaults = true
        do {
            let result = try context.fetch(request)
            print("FETCHED CORE DATA", result.count)
            for property in result as! [Property] {
                print("Fetched...")
                if property.imageData == nil || deletedPropertyIds.contains(property.objectId!) {
                    print("Deleting nil property")
                    context.delete(property)
                } else {
                    print(property.title)
                    property.image = UIImage(data: property.imageData!)!
                    fetchedProperties.append(property)
                }
            }
            return fetchedProperties
        } catch {
            print("Failed")
        }
        return fetchedProperties
    }
    
    func getDeletedProperties(completion: @escaping (_ result: [String])->()) {
        let query = PFQuery(className:"UpdatedProperties")
        query.whereKey("updateType", equalTo: "delete")
        query.getFirstObjectInBackground { (deletedObject: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let deletedObject = deletedObject {
                var deletedPropertyIds = [String]()
                for deletedProperty in deletedObject["propertyIds"] as! [String] {
                    deletedPropertyIds.append(deletedProperty)
                }
                completion(deletedPropertyIds)
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
                                    let updatedAt = object.updatedAt!
                                    let objectId = object.objectId!
                                    
                                    let updateAtRef = UpdatedAt()
                                    updateAtRef.saveTimestamp(timestamp: updatedAt, objectId: objectId)
                                    
                                    let property = self.savePropertyToCoreData(objectId: objectId, address: address, title: title, price: price, squareFootageLiveable: squareFootageLiveable, propertyType: propertyType, imageData: imageData!, createdAt: createdAt, updatedAt: updatedAt, image: finalimage)
                                    
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
