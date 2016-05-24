//
//  RadialGradientView.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/23.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class RadialGradientView: UIView {

    override func drawRect(rect: CGRect) {
        let colors = [
            UIColor.whiteColor().colorWithAlphaComponent(1).CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0).CGColor
        ]

        let context = UIGraphicsGetCurrentContext()

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bottomCenter = CGPointMake(center.x, frame.height)

        let gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
        CGContextDrawRadialGradient(context, gradient, bottomCenter, 20, bottomCenter, 350, .DrawsBeforeStartLocation)

    }
}
