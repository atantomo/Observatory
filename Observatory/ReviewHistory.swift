//
//  ReviewHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

final class ReviewHistory: NSManagedObject, ItemHistory {

    @NSManaged var reviewCount: NSNumber?
    @NSManaged var reviewAverage: NSNumber?
    @NSManaged var timestamp: NSDate
    
    @NSManaged var item: Item?

    var comparableData: NSNumber? {
        
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

    func makeDisplayData(previous: ReviewHistory?) -> ItemDisplay {

        return ReviewDisplay(history: self, previous: previous)
    }
}

struct ReviewDisplay: ItemDisplay {

    let data: String
    let reviewBarRelativeLength: Double
    let time: String
    let direction: ChangeDirection

    init(history: ReviewHistory, previous: ReviewHistory?) {

        self.data = Formatter.getDisplayReviewCount(history.reviewCount)
        self.reviewBarRelativeLength = Formatter.getRelativeLength(history.reviewAverage)
        self.time = Formatter.getDisplayDate(history.timestamp)
        self.direction = Formatter.getChangeDirection(history, previous: previous)
    }
}