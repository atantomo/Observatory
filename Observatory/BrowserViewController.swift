//
//  BrowserViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class BrowserViewController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var emptyPlaceholderView: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    /*var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }*/

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        RakutenClient.sharedInstance().getItem("misia", genreId: "") { items, errorMessage in

            print(items)
        }
    }


}
