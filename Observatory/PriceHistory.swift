//
//  PriceHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

final class PriceHistory: NSManagedObject, ItemHistory {

    @NSManaged var itemPrice: NSNumber?
    @NSManaged var timestamp: NSDate
    
    @NSManaged var item: Item?

    var comparableData: NSNumber? {
        
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
    }

    static func fetchStoredHistoryForItem(item: Item, context: NSManagedObjectContext) -> [PriceHistory] {

        let fetchRequest = NSFetchRequest(entityName: "PriceHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try context.executeFetchRequest(fetchRequest) as! [PriceHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [PriceHistory]()
        }
    }

    func makeDisplayData(previous: PriceHistory?) -> ItemDisplay {

        return PriceDisplay(history: self, previous: previous)
    }
}

struct PriceDisplay: ItemDisplay {

    let data: String
    let time: String
    let direction: ChangeDirection

    init(history: PriceHistory, previous: PriceHistory?) {

        self.data = Formatter.getDisplayPrice(history.itemPrice)
        self.time = Formatter.getDisplayDate(history.timestamp)
        self.direction = Formatter.getChangeDirection(history, previous: previous)
    }
}