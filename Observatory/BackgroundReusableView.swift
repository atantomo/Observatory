//
//  BackgroundReusableView.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/18.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class BackgroundReusableView: UICollectionReusableView {

    static let kind = "Background"

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

        backgroundColor = UIColor.whiteColor()
        alpha = 0.5

        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 0.5

        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.CGPath

        layer.shadowOpacity = 0.3
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }
}
