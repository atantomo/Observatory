//
//  LoaderView.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/02/20.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class LoaderView: UIView {

    var backgroundShade = UIView()
    var overlayWidth: CGFloat = 88

    
    override init(frame: CGRect) {

        super.init(frame: frame)
        setupLoaderView()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)!
        setupLoaderView()
    }

    func setupLoaderView() {

        backgroundShade = generateTransarentBackground()
        addSubview(backgroundShade)

        let overlayView = generateOverlayView()
        addSubview(overlayView)

        let activityIndicator = generateActivityIndicator()
        addSubview(activityIndicator)

        let activityLabel = generateLoadingLabel()
        addSubview(activityLabel)

        activityIndicator.startAnimating()
    }

    private func generateTransarentBackground() -> UIView {

        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        view.alpha = 0.3

        return view
    }

    // square-shaped overlay
    private func generateOverlayView() -> UIView {

        let frame = CGRectMake(0, 0, overlayWidth, overlayWidth)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.7
        view.layer.cornerRadius = 4.0
        view.center = center

        return view
    }

    private func generateActivityIndicator() -> UIActivityIndicatorView {

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = CGPointMake(center.x, center.y - 8.0)

        return activityIndicator
    }

    private func generateLoadingLabel() -> UILabel {

        let label = UILabel(frame: CGRectMake(0, 0, overlayWidth, overlayWidth))
        label.text = "Loading..."
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.center = CGPointMake(center.x, center.y + 24.0)

        return label
    }
}
