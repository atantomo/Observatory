//
//  ItemDetail.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/29.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation
import CoreData

internal enum ItemDetailType {

    case ItemName(displayText: String)
    case Availability(displayTexts: [(data: String, time: String)], shouldNotify: Bool)
    case Price(displayTexts: [(data: String, time: String)], shouldNotify: Bool)
    case Review(displayTexts: [(revCount: String, revBarLength: Double, time: String)], shouldNotify: Bool)
}

class ItemDetail {

    static var currencyFormatter: NSNumberFormatter = {

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        return formatter
    }()

    static var dateFormatter: NSDateFormatter = {

        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, d MMM yyyy"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return formatter
    }()

    let label: String
    let detailType: ItemDetailType

    static var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    

    init(label: String, detailType: ItemDetailType) {

        self.label = label
        self.detailType = detailType
    }

    static func generateTableContent(item: Item) -> [ItemDetail] {

        let itemName = getDisplayItemName(item.itemName)
        let price = generatePriceHistory(item)
        let rev = generateReviewHistory(item)
        let avail = generateDispAvailabilityHistory(item)

        let detail = [
            ItemDetail(label: "", detailType: .ItemName(displayText: itemName)),
            ItemDetail(label: "Price", detailType: .Price(displayTexts: price.displayTexts, shouldNotify: price.shouldNotify)),
            ItemDetail(label: "Review", detailType: .Review(displayTexts: rev.displayTexts, shouldNotify: rev.shouldNotify)),
            ItemDetail(label: "Availability", detailType: .Availability(displayTexts: avail.displayTexts, shouldNotify: avail.shouldNotify))
        ]
        return detail
    }

    static func generatePriceHistory(item: Item) -> (displayTexts: [(data: String, time: String)], shouldNotify: Bool) {

        var shouldNotify = false
        let priceHist = fetchStoredPriceHistory(item)

        for hist in priceHist {
            if hist.readFlg == false {
                shouldNotify = true
                break
            }
        }

        var dispPrice = priceHist.map { hist in
            (data: getDisplayPrice(hist.itemPrice), time: dateFormatter.stringFromDate(hist.timestamp))
        }
        dispPrice.insert((data: getDisplayPrice(item.itemPrice), time: dateFormatter.stringFromDate(item.timestamp)), atIndex: 0)

        return (dispPrice, shouldNotify)
    }

    static func generateReviewHistory(item: Item) -> (displayTexts: [(revCount: String, revBarLength: Double, time: String)], shouldNotify: Bool) {

        var shouldNotify = false
        let reviewHist = fetchStoredReviewHistory(item)

        for hist in reviewHist {
            if hist.readFlg == false {
                shouldNotify = true
                break
            }
        }

        var dispRev = reviewHist.map { hist in
            (revCount: getDisplayReviewCount(hist.reviewCount), revBarLength: getRelativeWidth(hist.reviewAverage), time: dateFormatter.stringFromDate(hist.timestamp))
        }
        dispRev.insert((revCount: getDisplayReviewCount(item.reviewCount), revBarLength: getRelativeWidth(item.reviewAverage), time: dateFormatter.stringFromDate(item.timestamp)), atIndex: 0)

        return (dispRev, shouldNotify)
    }

    static func generateDispAvailabilityHistory(item: Item) -> (displayTexts: [(data: String, time: String)], shouldNotify: Bool) {

        var shouldNotify = false
        let availabilityHist = fetchStoredAvailabilityHistory(item)

        for hist in availabilityHist {
            if hist.readFlg == false {
                shouldNotify = true
                break
            }
        }

        var dispAvail = availabilityHist.map { hist in
            (data: getDisplayAvailability(hist.availability), time: dateFormatter.stringFromDate(hist.timestamp))
        }
        dispAvail.insert((data: getDisplayAvailability(item.availability), time: dateFormatter.stringFromDate(item.timestamp)), atIndex: 0)

        return (dispAvail, shouldNotify)
    }

    static private func fetchStoredPriceHistory(item: Item) -> [PriceHistory] {

        let fetchRequest = NSFetchRequest(entityName: "PriceHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [PriceHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [PriceHistory]()
        }
    }

    static private func fetchStoredReviewHistory(item: Item) -> [ReviewHistory] {

        let fetchRequest = NSFetchRequest(entityName: "ReviewHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [ReviewHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [ReviewHistory]()
        }
    }

    static private func fetchStoredAvailabilityHistory(item: Item) -> [AvailabilityHistory] {

        let fetchRequest = NSFetchRequest(entityName: "AvailabilityHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "item == %@", item)

        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [AvailabilityHistory]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [AvailabilityHistory]()
        }
    }

    static func getDisplayItemName(itemName: String?) -> String {

        guard let itemName = itemName else {
            return "Unavailable"
        }
        return itemName
    }

    static func getDisplayPrice(price: NSNumber?) -> String {

        guard let price = price, let cur = currencyFormatter.stringFromNumber(price) else {
            return "Unavailable"
        }
        return cur
    }

    static func getDisplayAvailability(availability: NSNumber?) -> String {

        guard let availability = availability else {
            return "Unavailable"
        }
        if availability == 1 {
            return "Available"
        } else {
            return "Out of stock"
        }
    }

    static func getDisplayReviewCount(reviewCount: NSNumber?) -> String {

        guard let reviewCount = reviewCount else {
            return "Unavailable"
        }
        return "(" + String(reviewCount) + ")"
    }

    static func getRelativeWidth(number: NSNumber?) -> Double {

        guard let number = number else {
            return 0
        }
        return Double(number)
    }
}