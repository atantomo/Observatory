//
//  PriceHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class PriceHistory: NSManagedObject {

    @NSManaged var itemPrice: NSNumber?
    @NSManaged var timestamp: NSDate
    @NSManaged var readFlg: Bool
    
    @NSManaged var item: Item?

    var comparableHistory: NSNumber? {
        return itemPrice
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(itemPrice: NSNumber?, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("PriceHistory", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.itemPrice = itemPrice
        timestamp = NSDate()
        readFlg = false
    }
}



