//
//  UIViewController+Async.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

extension UIViewController {

    func displayAlertAsync(title: String, errorString: String?) {

        dispatch_async(dispatch_get_main_queue(), {
            let alertCtrl = UIAlertController(title: title, message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertCtrl.addAction(okAction)
            self.presentViewController(alertCtrl, animated: true, completion: nil)
        })
    }

    func displayErrorAsync(errorString: String?) {

        displayAlertAsync("Error", errorString: errorString)
    }

    func displayNoticeAsync(errorString: String?) {

        displayAlertAsync("Notice", errorString: errorString)
    }

    func removeViewAsync(view: UIView) {

        dispatch_async(dispatch_get_main_queue(), {
            view.removeFromSuperview()
        })
    }
}