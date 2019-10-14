//
//  Property.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class Property {
    var title: String
    var price: Double
    var squareFootageLiveable: Int
    var squareFootageTotal: Int
    var address: String
    var image: UIImage
    
    //Empty constructor
    init() {
        self.title = "Default Title"
        self.price = 0.0
        self.squareFootageLiveable = 0
        self.squareFootageTotal = 0
        self.address = "532 8th St NW, Atlanta, GA 30318"
        self.image = UIImage()
    }
    
    //Constructor with all params provided
    init(title: String, price: Double, squareFootageLiveable: Int , squareFootageTotal: Int, address: String, image: UIImage) {
        self.title = title
        self.price = price
        self.squareFootageLiveable = squareFootageLiveable
        self.squareFootageTotal = squareFootageTotal
        self.address = address
        self.image = image
    }
    
    func getProperties() -> [Property] {
        let addresses = ["708 Spring St NW, Atlanta, GA 30308", "532 8th St NW, Atlanta, GA 30318", "930 Spring St NW, Atlanta, GA 30309"]
        let prices = [4500000, 6000000, 100000]
        let squareFootageLiveableValues = [8000, 12000, 9000]
        let squareFootageTotalValues = [8000, 12000, 9000]
        let defaultPropertyImage = UIImage(named: "defaultProperty")!
        
        
        var properties = [Property]()
        for i in 0...2 {
            let newProperty = Property(title: "Title", price: Double(prices[i]), squareFootageLiveable: squareFootageLiveableValues[i], squareFootageTotal: squareFootageTotalValues[i],  address: addresses[i], image: defaultPropertyImage)
            properties.append(newProperty)
        }
        return properties
    }
}
