//
//  ReviewHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class ReviewHistory: NSManagedObject {

    @NSManaged var reviewCount: NSNumber?
    @NSManaged var reviewAverage: NSNumber?
    @NSManaged var timestamp: NSDate
    @NSManaged var readFlg: Bool
    
    @NSManaged var item: Item?

    var comparableHistory: NSNumber? {
        return reviewAverage
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(count: NSNumber?, average: NSNumber?, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("ReviewHistory", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        reviewCount = count
        reviewAverage = average
        timestamp = NSDate()
        readFlg = false
    }

    static func fetchStoredHistoryForItem(item: Item, context: NSManagedObjectContext) -> [ReviewHistory] {

        let fetchRequest = NSFetchRequest(entityName: "ReviewHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try context.executeFetchRequest(fetchRequest) as! [ReviewHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [ReviewHistory]()
        }
    }
}



