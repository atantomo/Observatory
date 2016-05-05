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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var emptyPlaceholderView: UIView!

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

        items = fetchStoredItems()
        setupViewInsets(itemCollectionView)

        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        itemCollectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        recalculateItemDimension(flowLayout)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SearchSettingSegue") {

            guard let navVc = segue.destinationViewController as? UINavigationController else {
                return
            }

            guard let settingVc = navVc.viewControllers.first as? SearchSettingViewController else {
                return
            }

            settingVc.searchSetting = searchSetting
            settingVc.delegate = self
        }

        if (segue.identifier == "BrowserDetailSegue") {

            guard let item = sender as? Item else {
                return
            }

            guard let navVc = segue.destinationViewController as? UINavigationController else {
                return
            }

            guard let detailVc = navVc.viewControllers.first as? ItemDetailViewController else {
                return
            }

            detailVc.selectedItem = item
        }
    }

    @IBAction func refreshBarButtonTapped(sender: UIBarButtonItem) {

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        let keyword = searchSetting.keyword
        let catId = searchSetting.category.id

        RakutenClient.sharedInstance().getItem(withKeyword: keyword, genreId: catId) { result in

            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(items):
                self.refreshItemsFromResult(items)

            case let .Error(err):

                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    private func fetchStoredItems() -> [Item] {

        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Item]
        } catch  let error as NSError {
            print("Error in fecthing items: \(error)")
            return [Item]()
        }
    }

    private func setupViewInsets(collectionView: UICollectionView) {

        collectionView.contentInset = UIEdgeInsetsMake(itemSpacer, itemSpacer, itemSpacer, itemSpacer)
    }

    private func recalculateItemDimension(layout: UICollectionViewFlowLayout) {

        layout.minimumLineSpacing = itemSpacer
        layout.minimumInteritemSpacing = itemSpacer

        // add spacing in between items and at both left/right ends
        let dimension = (self.view.frame.size.width - ((itemPerRow + 1) * itemSpacer)) / itemPerRow
        layout.itemSize = CGSizeMake(dimension, dimension)
    }

    private func refreshItemsFromResult(result: [[String: AnyObject]]?) {

        // remove previous items
        self.items.forEach {
            self.sharedContext.deleteObject($0)
        }

        // add new items
        if let retrievedItems = result {

            items = retrievedItems.map() { (dictionary: [String: AnyObject]) in
                Item(dictionary: dictionary, context: self.sharedContext)
            }
        }

        dispatch_async(dispatch_get_main_queue(), {

            self.itemCollectionView.reloadData()
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }

    private func configureCell(cell: ItemCollectionViewCell, withItem item: Item) {

        if let localImage = item.itemImage {
            cell.itemImageView.image = localImage

        } else {

            guard let imageUrl = item.imageUrl else {
                cell.itemImageView.image = nil
                return
            }

            let placeholderView = PlaceholderView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
            cell.addSubview(placeholderView)

            RakutenClient.sharedInstance().taskForImageWithUrl(imageUrl) { result in

                self.removeViewAsync(placeholderView)
                
                switch result {
                case let .Success(data):
                    dispatch_async(dispatch_get_main_queue()) {

                        let image = UIImage(data: data)
                        if (!item.fault) {
                            item.itemImage = image
                        }
                        cell.itemImageView.image = image
                    }
                case .Error:
                    cell.itemImageView.image = nil
                    return
                }
            }
        }
    }

}

extension BrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCollectionCell", forIndexPath: indexPath) as! ItemCollectionViewCell

        let item = items[indexPath.item]
        configureCell(cell, withItem: item)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("BrowserDetailSegue", sender: items[indexPath.item])
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

extension BrowserViewController: SearchSettingViewControllerDelegate {

    func searchSettingViewController(searchSetting: SearchSettingViewController, didRetrieveResult result: [[String : AnyObject]]?) {

        if let fetchedItems = result {
            self.refreshItemsFromResult(fetchedItems)
        }
    }
}