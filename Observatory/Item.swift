//
//  Item.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

enum ItemStatus: NSNumber {
    
    case Removed = -1
    case Normal = 0
    case New = 1
}

final class Item: NSManagedObject {

    @NSManaged var itemCode: String
    @NSManaged var itemName: String?
    @NSManaged var itemUrl: String?
    @NSManaged var imageUrl: String?
    @NSManaged var genreId: NSNumber?
    @NSManaged var timestamp: NSDate
    @NSManaged var itemStatus: NSNumber
    @NSManaged var readFlg: Bool

    @NSManaged var avilabilityHistories: [AvailabilityHistory]
    @NSManaged var priceHistories: [PriceHistory]
    @NSManaged var reviewHistories: [ReviewHistory]

    var status: ItemStatus {
        get {
            return ItemStatus(rawValue: itemStatus)!
        }
        set {
            itemStatus = newValue.rawValue
        }
    }

    var originalImageUrl: String? {

        return imageUrl?.componentsSeparatedByString("?").first
    }

    var itemImage: UIImage? {

        get {
            return RakutenClient.Caches.imageCache.imageWithIdentifier(fileName)
        }
        set {
            RakutenClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName)
        }
    }

    var originalImage: UIImage? {

        get {
            return RakutenClient.Caches.imageCache.imageWithIdentifier(originalFileName)
        }
        set {
            RakutenClient.Caches.imageCache.storeImage(newValue, withIdentifier: originalFileName)
        }
    }

    private var fileName: String {

        return itemCode.stringByReplacingOccurrencesOfString(":", withString: "_")
    }

    private var originalFileName: String {

        return fileName + "_original"
    }


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        updateItem(dictionary, shouldNotify: false, context: context)
        status = .New
        readFlg = true
    }

    override func prepareForDeletion() {

        RakutenClient.Caches.imageCache.storeImage(nil, withIdentifier: fileName)
        RakutenClient.Caches.imageCache.storeImage(nil, withIdentifier: originalFileName)
    }

    static func fetchStoredItems(context: NSManagedObjectContext) -> [Item] {

        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Item]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [Item]()
        }
    }

    static func groupByStatus(items: [Item]) -> [[Item]] {

        let newItems = items.filter { $0.status == .New }
        let observedItems = items.filter { $0.status == .Normal }
        let removedItems = items.filter { $0.status == .Removed }

        let groupedItems = [
            newItems,
            observedItems,
            removedItems
        ]
        return groupedItems
    }

    static func refreshItemsFromResult(currentItems: [[Item]], result: [String: [String: AnyObject]]?, context: NSManagedObjectContext) -> (updatedItems: [[Item]], hasNewUpdate: Bool) {

        var newItems = [Item]()
        var hasNewUpdate = false

        let items = currentItems.flatMap { $0 }
        if let retrievedItems = result {

            let currentItemCodes = items.map { item in
                item.itemCode
            }
            retrievedItems.forEach { (key, value) in

                if !currentItemCodes.contains(key) {

                    // add new item
                    hasNewUpdate = true
                    newItems.append(Item(dictionary: value, context: context))
                }
            }
            items.forEach { item in

                if let itemToUpdate = retrievedItems[item.itemCode] {

                    // update existing item
                    if item.updateItem(itemToUpdate, shouldNotify: true, context: context) {
                        hasNewUpdate = true
                    }
                    if item.status != .Normal {
                        hasNewUpdate = true
                        item.status = .Normal
                    }

                } else {

                    // remove item   
                    if item.status != .Removed {
                        hasNewUpdate = true
                        item.status = .Removed
                    }
                }
                newItems.append(item)
            }
        }
        return (updatedItems: Item.groupByStatus(newItems), hasNewUpdate: hasNewUpdate)
    }


    func updateItem(dictionary: [String: AnyObject], shouldNotify: Bool, context: NSManagedObjectContext) -> Bool {

        setStaticData(dictionary)
        let priceUpdated = updatePrice(dictionary, shouldNotify: shouldNotify, context: context)
        let reviewUpdated = updateReview(dictionary, shouldNotify: shouldNotify, context: context)
        let availabilityUpdated = updateAvailability(dictionary, shouldNotify: shouldNotify, context: context)

        return priceUpdated || reviewUpdated || availabilityUpdated
    }

    private func setStaticData(dictionary: [String: AnyObject]) {

        itemCode = dictionary[Constants.Rakuten.JSONResponse.Code] as! String
        itemName = dictionary[Constants.Rakuten.JSONResponse.Name] as? String
        itemUrl = dictionary[Constants.Rakuten.JSONResponse.Url] as? String
        genreId = dictionary[Constants.Rakuten.JSONResponse.GenreId] as? NSNumber
        timestamp = NSDate()

        if let urls = dictionary[Constants.Rakuten.JSONResponse.ImageUrlM] as? [[String:String]],
            let url = urls.first?[Constants.Rakuten.JSONResponse.ImageUrl] {

            imageUrl = url
        }
    }

    private func updatePrice(dictionary: [String: AnyObject], shouldNotify: Bool, context: NSManagedObjectContext) -> Bool {

        let updPrice = dictionary[Constants.Rakuten.JSONResponse.Price] as? NSNumber

        let priceHistories = PriceHistory.fetchStoredHistoryForItem(self, context: context)
        let lastStoredPrice = priceHistories.first?.itemPrice

        if lastStoredPrice != updPrice {

            let priceHistory = PriceHistory(itemPrice: updPrice, context: context)
            priceHistory.item = self
            readFlg = !shouldNotify
            return true
        }
        return false
    }

    private func updateAvailability(dictionary: [String: AnyObject], shouldNotify: Bool, context: NSManagedObjectContext) -> Bool {

        let updAvail = dictionary[Constants.Rakuten.JSONResponse.Availability] as? NSNumber

        let availabilityHistories = AvailabilityHistory.fetchStoredHistoryForItem(self, context: context)
        let lastStoredAvail = availabilityHistories.first?.availability

        if lastStoredAvail != updAvail {

            let availabilityHistory = AvailabilityHistory(availability: updAvail, context: context)
            availabilityHistory.item = self
            readFlg = !shouldNotify
            return true
        }
        return false
    }

    private func updateReview(dictionary: [String: AnyObject], shouldNotify: Bool, context: NSManagedObjectContext) -> Bool {

        let updRevCount = dictionary[Constants.Rakuten.JSONResponse.ReviewCount] as? NSNumber
        let updRevAvg = dictionary[Constants.Rakuten.JSONResponse.ReviewAverage] as? NSNumber

        let reviewHistories = ReviewHistory.fetchStoredHistoryForItem(self, context: context)
        let lastStoredRevCount = reviewHistories.first?.reviewCount
        let lastStoredRevAvg = reviewHistories.first?.reviewAverage

        if lastStoredRevCount != updRevCount || lastStoredRevAvg != updRevAvg {

            let reviewHistory = ReviewHistory(count: updRevCount, average: updRevAvg, context: context)
            reviewHistory.item = self
            readFlg = !shouldNotify
            return true
        }
        return false
    }
}

class GroupedItemData {

    static var data = [[Item]]()
}



