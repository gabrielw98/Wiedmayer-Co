//
//  UpdatedAt+CoreDataClass.swift
//  
//
//  Created by Gabe Wilson on 11/18/19.
//
//

import Foundation
import CoreData

@objc(UpdatedAt)
public class UpdatedAt: NSManagedObject {
    
    func fetchUpdatedAtTimestamps() -> [Date] {
        var updatedAtList = [Date]()
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UpdatedAt")
        do {
            let result = try context.fetch(request)
            for object in result as! [UpdatedAt] {
                updatedAtList.append(object.updatedAt!)
            }
            return updatedAtList
        } catch {
            print("Error: Failed to fetch the updatedAt timestamps")
        }
        return updatedAtList
    }
    
    func deleteAllTimestamps() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UpdatedAt")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = CoreDataManager.shared.persistentContainer.viewContext

        do {
            try context.execute(deleteRequest)
            print()
            print("Success: Deleted all the timestamps")
            print(self.fetchUpdatedAtTimestamps())
        } catch let error as NSError {
            print("Error:", error)
        }
    }
    
    func deleteTimeStampFromCoreData(objectId: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UpdatedAt")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            print("Success: Deleted the timestamp associated with", objectId)
            print(self.fetchUpdatedAtTimestamps())
        } catch {
            // Error Handling
            print("Failed: Could not delete timestamp", error)
        }
    }
    
    func saveTimestamp(timestamp: Date, objectId: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UpdatedAt", in: context)
        let newTimestamp = NSManagedObject(entity: entity!, insertInto: context) as! UpdatedAt
        newTimestamp.updatedAt = timestamp
        newTimestamp.objectId = objectId
        do {
            try context.save()
            print("Success: Saved the updated timestamp", timestamp, objectId)
          } catch {
           print("Error: Failed Saving Timestamp to Core Data")
        }
    }
    
    func updateTimestamp(objectId: String, timestamp: Date) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = NSBatchUpdateRequest(entityName: "UpdatedAt")
        request.predicate = NSPredicate(format: "objectId = %@", objectId)
        request.propertiesToUpdate = ["updatedAt" : timestamp]
        do {
            try context.execute(request)
            print("Success: Updated the timestamp of \(objectId) to \(timestamp)")
        } catch {
            // Error Handling
            print("Error: Attempted to update timestamp in Core Data failed with \(error)")
        }
    }

}
