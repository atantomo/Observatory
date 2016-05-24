//
//  ItemCollectionViewCell.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var noImageView: UIView!
    @IBOutlet weak var itemFrameView: UIView!
    @IBOutlet weak var notificationIcon: UIImageView!

    override func drawRect(rect: CGRect) {

        itemFrameView.layer.borderColor = UIColor.lightGrayColor().CGColor
        itemFrameView.layer.borderWidth = 0.5
    }
}
