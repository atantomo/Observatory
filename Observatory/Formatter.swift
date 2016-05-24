//
//  Formatter.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/15.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

private var dateFormatter: NSDateFormatter = {

    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "d MMM yyyy"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return formatter
}()

private var currencyFormatter: NSNumberFormatter = {

    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.locale = NSLocale(localeIdentifier: "ja_JP")
    return formatter
}()

struct Formatter {

    static func getDisplayName(name: String?) -> String {

        guard let name = name else {
            return "Unavailable"
        }
        return name
    }

    static func getDisplayDate(date: NSDate) -> String {

        return dateFormatter.stringFromDate(date)
    }

    static func getChangeDirection<T: ItemHistory>(history: T, previous: T?) -> ChangeDirection {

        if let current = history.comparableData as? Int,
            let previous = previous?.comparableData as? Int {

            if current > previous {
                return .Up
            } else if current < previous {
                return .Down
            }
        }
        return .None
    }

    static func getDisplayAvailability(availability: NSNumber?) -> String {

        guard let dispAvailability = availability else {
            return "Unavailable"
        }
        if dispAvailability == 1 {
            return "Available"
        } else {
            return "Out of stock"
        }
    }

    static func getDisplayPrice(price: NSNumber?) -> String {

        guard let price = price, let dispPrice = currencyFormatter.stringFromNumber(price) else {
            return "Unavailable"
        }
        return dispPrice
    }

    static func getDisplayReviewCount(reviewCount: NSNumber?) -> String {

        guard let dispReviewCount = reviewCount else {
            return "Unavailable"
        }
        return "(" + String(dispReviewCount) + ")"
    }
    
    static func getRelativeLength(length: NSNumber?) -> Double {
        
        guard let relLength = length else {
            return 0
        }
        return Double(relLength)
    }

}