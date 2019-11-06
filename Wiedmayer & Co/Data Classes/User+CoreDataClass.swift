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
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = CoreDataManager.shared.context

        do {
            print("deleted this...")
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print("Error:", error)
        }
        self.isNewUser()
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
        
        /*do {
           try context.save()
          } catch {
           print("Error: Failed Saving Property To Core Data")
        }*/
        return newUser
    }
}
