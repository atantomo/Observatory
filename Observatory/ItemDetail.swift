//
//  ItemDetail.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/29.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation
import CoreData

enum ItemDetailType {

    case Static(data: String)
    case Traceable(data: [ItemDisplay])
}

struct ItemDetail {

    let label: String
    let detailType: ItemDetailType

    init(label: String, detailType: ItemDetailType) {

        self.label = label
        self.detailType = detailType
    }

    static func generateTableContent(item: Item, context: NSManagedObjectContext) -> [ItemDetail] {

        let itemName = generateStaticDetail(item.itemName)

        let priceHistories = PriceHistory.fetchStoredHistoryForItem(item, context: context)
        let price = generateTraceableDetail(priceHistories)

        let reviewHistories = ReviewHistory.fetchStoredHistoryForItem(item, context: context)
        let rev = generateTraceableDetail(reviewHistories)

        let availabilityHistories = AvailabilityHistory.fetchStoredHistoryForItem(item, context: context)
        let avail = generateTraceableDetail(availabilityHistories)

        let detail = [
            ItemDetail(label: "", detailType: itemName),
            ItemDetail(label: "Price", detailType: price),
            ItemDetail(label: "Review", detailType: rev),
            ItemDetail(label: "Availability", detailType: avail)
        ]
        return detail
    }

    static func generateStaticDetail(data: String?) -> ItemDetailType {

        let dispData = Formatter.getDisplayName(data)
        return .Static(data: dispData)
    }

    static func generateTraceableDetail<T: ItemHistory>(histories: [T]) -> ItemDetailType {

        let displaydata = histories.enumerate().map { (index, history) -> ItemDisplay in

            let previousHistIndex = index + 1 // + 1 because order is reversed
            if histories.indices.contains(previousHistIndex) {

                let previousHistory = histories[previousHistIndex]
                return history.makeDisplayData(previousHistory)

            } else {
                return history.makeDisplayData(nil)
            }
        }
        return .Traceable(data: displaydata)
    }
}