//
//  InsetTextField.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    var inset: CGFloat = 20.0

    override func textRectForBounds(bounds: CGRect) -> CGRect {

        return bounds.trimWidth(left: inset, right: inset)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {

        return bounds.trimWidth(left: inset, right: inset)
    }

    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {

        let buttonRect = super.clearButtonRectForBounds(bounds)
        let startX = bounds.width - buttonRect.width - inset

        return bounds.trimWidth(left: startX, right: inset)
    }
}

extension CGRect {

    func trimWidth(left left: CGFloat, right: CGFloat) -> CGRect {

        return CGRectMake(left, 0, self.width - left - right, self.height)
    }
}