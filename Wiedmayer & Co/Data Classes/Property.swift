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

class Property {
    var title: String
    var price: Int
    var squareFootageLiveable: Int
    var squareFootageTotal: Int
    var address: String
    var image: UIImage
    var createdAt: Date
    
    // array of properties returned from the query
    var properties = [Property]()
    
    //Empty constructor
    init() {
        self.title = ""
        self.price = 0
        self.squareFootageLiveable = 0
        self.squareFootageTotal = 0
        self.address = ""
        self.image = UIImage()
        self.createdAt = Date()
    }
    
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
        if squareFootageTotal == 0 {
            missingAttributes.append("Square Footage Total")
        }
        if address == "" {
            missingAttributes.append("Address")
        }
        return missingAttributes
    }
    
    func isValid() -> Bool {
        return self.title != "" && self.price != 0 && self.squareFootageLiveable != 0 && self.squareFootageTotal != 0 && self.address != ""
    }
    
    //Constructor with all params provided
    init(title: String, price: Int, squareFootageLiveable: Int , squareFootageTotal: Int, address: String, image: UIImage, createdAt: Date) {
        self.title = title
        self.price = price
        self.squareFootageLiveable = squareFootageLiveable
        self.squareFootageTotal = squareFootageTotal
        self.address = address
        self.image = image
        self.createdAt = createdAt
    }
    
    /*func getProperties() -> [Property] {
        let addresses = ["708 Spring St NW, Atlanta, GA 30308", "532 8th St NW, Atlanta, GA 30318", "930 Spring St NW, Atlanta, GA 30309"]
        let prices = [4500000, 6000000, 100000]
        let squareFootageLiveableValues = [8000, 12000, 9000]
        let squareFootageTotalValues = [8000, 12000, 9000]
        let defaultPropertyImage = UIImage(named: "defaultProperty")!
        
        
        var properties = [Property]()
        for i in 0...2 {
            let newProperty = Property(title: "Title", price: prices[i], squareFootageLiveable: squareFootageLiveableValues[i], squareFootageTotal: squareFootageTotalValues[i],  address: addresses[i], image: defaultPropertyImage)
            properties.append(newProperty)
        }
        return properties
    }*/
    
    func orderByCreatedAtAscending(properties: [Property]) -> [Property] {
        return properties.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == ComparisonResult.orderedDescending })
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
                                    let squareFootageTotal = object["squareFootageTotal"] as! Int
                                    let address = object["address"] as! String
                                    let createdAt = object.createdAt!
                                    let property = Property(title: title, price: price, squareFootageLiveable: squareFootageLiveable, squareFootageTotal: squareFootageTotal, address: address, image: UIImage(), createdAt: createdAt)
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
