//
//  ItemHistory.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

protocol ItemHistory {

    var comparableData: NSNumber? { get }
    func makeDisplayData(previous: Self?) -> ItemDisplay
}