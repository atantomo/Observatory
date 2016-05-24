//
//  ItemDisplay.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

protocol ItemDisplay {

    var data: String { get }
    var time: String { get }
    var direction: ChangeDirection { get }
}

enum ChangeDirection {

    case Up
    case Down
    case None
}
