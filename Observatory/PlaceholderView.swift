//
//  PlaceholderView.swift
//  Virtual Tourist
//
//  Created by Andrew Tantomo on 2016/03/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class PlaceholderView: UIView {

    override init(frame: CGRect) {

        super.init(frame: frame)
        setupPlaceholderView()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)!
        setupPlaceholderView()
    }

    func setupPlaceholderView() {

        let backgroundShade = generateOpaqueBackground()
        addSubview(backgroundShade)

        let activityIndicator = generateActivityIndicator()
        addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }

    private func generateOpaqueBackground() -> UIView {

        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.darkGrayColor()

        return view
    }

    private func generateActivityIndicator() -> UIActivityIndicatorView {

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = center

        return activityIndicator
    }
    
}
