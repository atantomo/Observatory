//
//  ReviewTableViewCell.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/04.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet weak var reviewDetailLabel: UILabel!
    @IBOutlet weak var reviewBarContainerView: UIView!
    @IBOutlet weak var reviewBarView: UIView!
    @IBOutlet weak var emptyReviewBarView: UIView!
    @IBOutlet weak var reviewBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeDirectionIcon: UIImageView!
    @IBOutlet weak var changeDirectionIconContainerWidthConstraint: NSLayoutConstraint!

    private var starImageView: UIImageView {

        return UIImageView(image: UIImage(named: "star"))
    }

    func setReviewBarLength(length: Double) {

        let reviewBarRealLength = CGFloat(length) / 5.0 * self.reviewBarContainerView.frame.width
        self.reviewBarWidthConstraint.constant = reviewBarRealLength

        let reviewBarkMaskImage = starImageView
        self.reviewBarView.maskView = reviewBarkMaskImage

        let emptyReviewBarMaskImage = starImageView
        emptyReviewBarMaskImage.frame = self.reviewBarContainerView.bounds
        emptyReviewBarMaskImage.frame.origin.x = -reviewBarRealLength
        self.emptyReviewBarView.maskView = emptyReviewBarMaskImage
        
    }
}
