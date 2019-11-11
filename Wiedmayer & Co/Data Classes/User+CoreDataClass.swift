//
//  User+CoreDataClass.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 11/6/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    func isNewUser() -> Bool {
        let context = CoreDataManager.shared.context
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            print(result.count)
            if result.count == 0 {
                // TODO
                // 1) query new
                print("User does not exist")
                return true
            }
        } catch {
            print("Error: Failed to fetch user")
        }
        return false
    }
    
    func deleteUserFromCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let context = CoreDataManager.shared.context

        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
        self.isNewUser()
    }

    func updateLastQuery() {
        let context = CoreDataManager.shared.context
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        // Helpers
        var result = [NSManagedObject]()

        do {
            // Execute Fetch Request
            let records = try? context.fetch(fetchRequest)

            if let records = records as? [NSManagedObject] {
                result = records
                result[0].setValue(Date(), forKey: "lastQuery")
                do {
                    print("Success: Updated the time stamp")
                   try context.save()
                  } catch {
                   print("Error: Failed Saving Property To Core Data")
                }
            }
        }
    }
    
    func fetchLastQueryTimestamp() -> Date {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        // Helpers
        var result = [NSManagedObject]()

        do {
            // Execute Fetch Request
            let records = try? CoreDataManager.shared.context.fetch(fetchRequest)

            if let records = records as? [User] {
                return records[0].lastQuery!
            }
        }
        return Date()
    }
    
    func saveUserToCoreData() -> User {
        let context = CoreDataManager.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context) as! User
        let lastYear = Calendar.current.date(
            byAdding: .year,
        value: -1,
        to: Date())
        newUser.lastQuery = lastYear
        
        do {
            print("saving new user")
           try context.save()
          } catch {
           print("Error: Failed Saving Property To Core Data")
        }
        return newUser
    }
}
