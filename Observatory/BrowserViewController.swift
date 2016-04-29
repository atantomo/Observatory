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

    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var emptyPlaceholderView: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var items = [Item]()
    var searchSetting = SearchSetting.unarchivedInstance() ?? SearchSetting()

    private let itemSpacer: CGFloat = 8.0
    private let itemPerRow: CGFloat = 3.0

    var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let keyword = searchSetting.keyword
        let catId = String(searchSetting.category.id)

        RakutenClient.sharedInstance().getItem(withKeyword: keyword, genreId: catId) { items, errorMessage in

            //print(items)

            if let fetchedItems = items {

                self.items = fetchedItems.map() { (dictionary: [String: AnyObject]) in
                    Item(dictionary: dictionary, context: self.sharedContext)
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.itemCollectionView.reloadData()
                })
            }
        }

        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self

        setupViewInsets()
        recalculateItemDimension()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SearchSetting") {

            guard let navVc = segue.destinationViewController as? UINavigationController else {
                return
            }

            guard let vc = navVc.viewControllers.first as? SearchSettingViewController else {
                return
            }

            vc.searchSetting = searchSetting
            vc.delegate = self
        }
    }

    private func recalculateItemDimension() {

        // add spacing in between items and at both left/right ends
        let dimension = (self.view.frame.size.width - ((itemPerRow + 1) * itemSpacer)) / itemPerRow
        flowLayout.minimumLineSpacing = itemSpacer
        flowLayout.minimumInteritemSpacing = itemSpacer
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }

    private func setupViewInsets() {

        itemCollectionView.contentInset = UIEdgeInsetsMake(itemSpacer, itemSpacer, itemSpacer, itemSpacer)
    }

}

extension BrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCollectionCell", forIndexPath: indexPath) as! ItemCollectionViewCell

        guard let url = items[indexPath.item].imageUrl else {
            collectionCell.itemImageView.image = nil
            return collectionCell
        }

        RakutenClient.sharedInstance().taskForImageWithUrl(url) { result in

            switch result {
            case .Success(let data):
                dispatch_async(dispatch_get_main_queue()) {
                    let image = UIImage(data: data!)

                    collectionCell.itemImageView.image = image
                }
            case .Error:
                return
            }
        }

        return collectionCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

//        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
//        toggleCellAlpha(cell)
//        toggleToolbar()
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

//        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
//        toggleCellAlpha(cell)
//        toggleToolbar()
    }

}

extension BrowserViewController: SearchSettingViewControllerDelegate {

    func searchSettingViewController(searchSetting: SearchSettingViewController, didRetrieveResult result: [[String : AnyObject]]?) {

        items.removeAll()
        if let fetchedItems = result {

            self.items = fetchedItems.map() { (dictionary: [String: AnyObject]) in
                Item(dictionary: dictionary, context: self.sharedContext)
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.itemCollectionView.reloadData()
            })
        }
    }
}