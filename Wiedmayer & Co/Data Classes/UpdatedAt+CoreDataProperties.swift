//
//  UpdatedAt+CoreDataProperties.swift
//  
//
//  Created by Gabe Wilson on 11/18/19.
//
//

import Foundation
import CoreData


extension UpdatedAt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UpdatedAt> {
        return NSFetchRequest<UpdatedAt>(entityName: "UpdatedAt")
    }

    @NSManaged public var updatedAt: Date?
    @NSManaged public var objectId: String?

}
