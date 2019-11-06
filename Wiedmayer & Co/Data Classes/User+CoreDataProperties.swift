//
//  User+CoreDataProperties.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 11/6/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var lastQuery: Date?
    @NSManaged public var adminStatus: String?

}
