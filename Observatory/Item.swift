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
    @NSManaged var itemPrice: String?
    @NSManaged var imageUrl: String?
    @NSManaged var availability: String?
    @NSManaged var reviewCount: NSNumber?
    @NSManaged var reviewAverage: NSNumber?
    @NSManaged var genreId: NSNumber?

    @NSManaged var collectionFlg: Bool

    var fileName: String {

        return String(itemCode)
    }

    var locationImage: UIImage? {

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
        itemPrice = dictionary[Constants.Rakuten.JSONResponse.Price] as? String
        availability = dictionary[Constants.Rakuten.JSONResponse.Availability] as? String
        reviewCount = dictionary[Constants.Rakuten.JSONResponse.ReviewCount] as? NSNumber
        reviewAverage = dictionary[Constants.Rakuten.JSONResponse.ReviewAverage] as? NSNumber
        genreId = dictionary[Constants.Rakuten.JSONResponse.GenreId] as? NSNumber

        if let urls = dictionary[Constants.Rakuten.JSONResponse.ImageUrlM] as? [[String:String]],
            let url = urls.first?[Constants.Rakuten.JSONResponse.ImageUrl] {

            imageUrl = url
        }

        collectionFlg = false
    }

    override func prepareForDeletion() {

        RakutenClient.Caches.imageCache.storeImage(nil, withIdentifier: fileName)
    }
}



