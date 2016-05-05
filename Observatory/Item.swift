//
//  Item.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/13.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class Item: NSManagedObject {

    @NSManaged var itemCode: String
    @NSManaged var itemName: String?
    @NSManaged var itemPrice: NSNumber?
    @NSManaged var itemUrl: String?
    @NSManaged var imageUrl: String?
    @NSManaged var availability: NSNumber?
    @NSManaged var reviewCount: NSNumber?
    @NSManaged var reviewAverage: NSNumber?
    @NSManaged var genreId: NSNumber?
    @NSManaged var timestamp: NSDate
    @NSManaged var observeFlg: Bool
    @NSManaged var readFlg: Bool

    @NSManaged var avilabilityHistories: [AvailabilityHistory]
    @NSManaged var priceHistories: [PriceHistory]
    @NSManaged var reviewHistories: [ReviewHistory]

    var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    var fileName: String {
        
        return itemCode.stringByReplacingOccurrencesOfString(":", withString: "_")
    }

    var itemImage: UIImage? {

        get {
            return RakutenClient.Caches.imageCache.imageWithIdentifier(fileName)
        }
        set {
            RakutenClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName)
        }
    }


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        itemCode = dictionary[Constants.Rakuten.JSONResponse.Code] as! String
        itemName = dictionary[Constants.Rakuten.JSONResponse.Name] as? String
        itemPrice = dictionary[Constants.Rakuten.JSONResponse.Price] as? NSNumber
        itemUrl = dictionary[Constants.Rakuten.JSONResponse.Url] as? String
        availability = dictionary[Constants.Rakuten.JSONResponse.Availability] as? NSNumber
        reviewCount = dictionary[Constants.Rakuten.JSONResponse.ReviewCount] as? NSNumber
        reviewAverage = dictionary[Constants.Rakuten.JSONResponse.ReviewAverage] as? NSNumber
        genreId = dictionary[Constants.Rakuten.JSONResponse.GenreId] as? NSNumber

        if let urls = dictionary[Constants.Rakuten.JSONResponse.ImageUrlM] as? [[String:String]],
            let url = urls.first?[Constants.Rakuten.JSONResponse.ImageUrl] {

            imageUrl = url
        }

        timestamp = NSDate()
        readFlg = false
        observeFlg = false
    }

    override func prepareForDeletion() {

        RakutenClient.Caches.imageCache.storeImage(nil, withIdentifier: fileName)
    }

    func updateItem(dictionary: [String: AnyObject]) {

        itemName = dictionary[Constants.Rakuten.JSONResponse.Name] as? String
        itemUrl = dictionary[Constants.Rakuten.JSONResponse.Url] as? String
        genreId = dictionary[Constants.Rakuten.JSONResponse.GenreId] as? NSNumber

        if let urls = dictionary[Constants.Rakuten.JSONResponse.ImageUrlM] as? [[String:String]],
            let url = urls.first?[Constants.Rakuten.JSONResponse.ImageUrl] {

            imageUrl = url
        }

        timestamp = NSDate()

        let updatePrice = dictionary[Constants.Rakuten.JSONResponse.Price] as? NSNumber
        let updateReviewCount = dictionary[Constants.Rakuten.JSONResponse.ReviewCount] as? NSNumber
        let updateReviewAverage = dictionary[Constants.Rakuten.JSONResponse.ReviewAverage] as? NSNumber
        let updateAvailability = dictionary[Constants.Rakuten.JSONResponse.Availability] as? NSNumber

        if itemPrice != updatePrice {

            let priceHistory = PriceHistory(itemPrice: itemPrice, context: sharedContext)
            priceHistory.item = self

            itemPrice = updatePrice
            readFlg = false
        }

        if availability != updateAvailability {

            let availabilityHistory = AvailabilityHistory(availability: availability, context: sharedContext)
            availabilityHistory.item = self

            availability = updateAvailability
            readFlg = false
        }

        if reviewCount != updateReviewCount || reviewAverage != updateReviewAverage {

            let reviewHistory = ReviewHistory(count: reviewCount, average: reviewAverage, context: sharedContext)
            reviewHistory.item = self

            reviewCount = updateReviewCount
            reviewAverage = updateReviewAverage
            readFlg = false
        }
    }
}



