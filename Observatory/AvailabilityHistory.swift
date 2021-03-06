//
//  AvailabilityHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

final class AvailabilityHistory: NSManagedObject, ItemHistory {

    @NSManaged var availability: NSNumber?
    @NSManaged var timestamp: NSDate

    @NSManaged var item: Item?

    var comparableData: NSNumber? {
        
        return availability
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(availability: NSNumber?, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("AvailabilityHistory", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.availability = availability
        timestamp = NSDate()
    }

    static func fetchStoredHistoryForItem(item: Item, context: NSManagedObjectContext) -> [AvailabilityHistory] {

        let fetchRequest = NSFetchRequest(entityName: "AvailabilityHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try context.executeFetchRequest(fetchRequest) as! [AvailabilityHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [AvailabilityHistory]()
        }
    }

    func makeDisplayData(previous: AvailabilityHistory?) -> ItemDisplay {

        return AvailabilityDisplay(history: self, previous: previous)
    }
}

struct AvailabilityDisplay: ItemDisplay {

    let data: String
    let time: String
    let direction: ChangeDirection

    init(history: AvailabilityHistory, previous: AvailabilityHistory?) {

        self.data = Formatter.getDisplayAvailability(history.availability)
        self.time = Formatter.getDisplayDate(history.timestamp)
        self.direction = Formatter.getChangeDirection(history, previous: previous)
    }
}