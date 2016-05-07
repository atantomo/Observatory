//
//  TraceableTableViewCell.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/05.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class TraceableTableViewCell: UITableViewCell {

    @IBOutlet weak var traceableTextLabel: UILabel!
    @IBOutlet weak var traceableDetailLabel: UILabel!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationContainerWidthConstraint: NSLayoutConstraint!
}