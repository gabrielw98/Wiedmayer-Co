//
//  Property+CoreDataProperties.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 11/4/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension Property {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Property> {
        return NSFetchRequest<Property>(entityName: "Property")
    }

    @NSManaged public var address: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var imageData: Data?
    @NSManaged public var objectId: String?
    @NSManaged public var price: Int64
    @NSManaged public var propertyType: String?
    @NSManaged public var squareFootageLiveable: Int64
    @NSManaged public var title: String?
    

}
