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

    var searchSetting = SearchSetting.unarchivedInstance() ?? SearchSetting()

    var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupViewInsets(itemCollectionView)

        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        
        let items = Item.fetchStoredItems(sharedContext)
        GroupedItemData.data = Item.groupByStatus(items)
        itemCollectionView.reloadData()
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

            guard let indexPath = sender as? NSIndexPath else {
                return
            }
            guard let navVc = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let detailVc = navVc.viewControllers.first as? ItemDetailViewController else {
                return
            }
            
            let item = GroupedItemData.data[indexPath.section][indexPath.item]
            item.readFlg = true
            CoreDataStackManager.sharedInstance().saveContext()

            detailVc.selectedItem = item
            itemCollectionView.reloadData()
        }
    }

    @IBAction func updateBarButtonTapped(sender: UIBarButtonItem) {

        guard !(GroupedItemData.data.flatMap { $0 }).isEmpty else {
            displayErrorAsync("There is no data to update")
            return
        }

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        let keyword = searchSetting.keyword
        let catId = searchSetting.category.id

        RakutenClient.sharedInstance().getIndexedRawItem(withKeyword: keyword, genreId: catId) { result in

            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(fetchedItems):
                dispatch_async(dispatch_get_main_queue(), {

                    let (updatedItems, hasNewUpdate) = Item.refreshItemsFromResult(GroupedItemData.data, result: fetchedItems, context: self.sharedContext)

                    GroupedItemData.data = updatedItems
                    if !hasNewUpdate {
                        self.displayNoticeAsync("There were no changes since last update")
                    } else {
                        self.displayNoticeAsync("Update successful!")
                    }
                    CoreDataStackManager.sharedInstance().saveContext()
                    self.itemCollectionView.reloadData()
                })

            case let .Error(err):
                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    private func setupViewInsets(collectionView: UICollectionView) {

        collectionView.contentInset = UIEdgeInsetsMake(Constants.Size.Medium, Constants.Size.Medium, Constants.Size.Medium, Constants.Size.Medium)
    }

    private func configureCell(cell: ItemCollectionViewCell, withItem item: Item) {

        if let localImage = item.itemImage {
            cell.itemImageView.image = localImage
            cell.noImageView.hidden = true

        } else if let imageUrl = item.imageUrl {

            let placeholderView = PlaceholderView(frame: cell.bounds)
            cell.addSubview(placeholderView)

            RakutenClient.sharedInstance().taskForImageWithUrl(imageUrl) { result in

                self.removeViewAsync(placeholderView)
                
                switch result {
                case let .Success(data):
                    dispatch_async(dispatch_get_main_queue()) {

                        let image = UIImage(data: data)
                        item.itemImage = image
                        cell.itemImageView.image = image
                        cell.noImageView.hidden = true
                    }
                case .Error:
                    cell.itemImageView.image = nil
                    cell.noImageView.hidden = false
                    return
                }
            }
        } else {

            cell.itemImageView.image = nil
            cell.noImageView.hidden = false
        }

        switch item.status {
        case .Removed:
            cell.alpha = 0.3
        default:
            break
        }

        if !item.readFlg {
            cell.notificationIcon.image = UIImage(named: "exclamation")
        } else {
            cell.notificationIcon.image = nil
        }
    }

}

extension BrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return GroupedItemData.data.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return GroupedItemData.data[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCollectionCell", forIndexPath: indexPath) as! ItemCollectionViewCell
        let item = GroupedItemData.data[indexPath.section][indexPath.item]
        configureCell(cell, withItem: item)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("BrowserDetailSegue", sender: indexPath)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "ItemCollectionHeader", forIndexPath: indexPath) as! HeaderCollectionReusableView

            switch indexPath.section {
            case 0:
                cell.headerLabel.text = "NEW"
            case 1:
                cell.headerLabel.text = "OBSERVING"
            case 2:
                cell.headerLabel.text = "OUT OF SIGHT"
            default:
                cell.headerLabel.text = ""
            }
            
            return cell

        } else if kind == UICollectionElementKindSectionFooter {

            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "EmptyCollectionCell", forIndexPath: indexPath)
            return cell
        }

        return UICollectionReusableView()
    }
}

extension BrowserViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if GroupedItemData.data[section].isEmpty {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return CGSizeMake(collectionView.frame.width, flowLayout.headerReferenceSize.height)

        } else {
            return CGSizeZero
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        if GroupedItemData.data[section].isEmpty {
            return UIEdgeInsetsZero
        }
        return UIEdgeInsetsMake(Constants.Size.Small, Constants.Size.Small, Constants.Size.Small, Constants.Size.Small)
    }
}

extension BrowserViewController: SearchSettingViewControllerDelegate {

    func searchSettingViewController(searchSetting: SearchSettingViewController, didRetrieveResult result: [String: [String : AnyObject]]?) {

        let items = GroupedItemData.data.flatMap { $0 }
        items.forEach { item in
            sharedContext.deleteObject(item)
        }
        GroupedItemData.data.removeAll()

        if let fetchedItems = result {
            dispatch_async(dispatch_get_main_queue(), {

                let (updatedItems, _) = Item.refreshItemsFromResult(GroupedItemData.data, result: fetchedItems, context: self.sharedContext)

                GroupedItemData.data = updatedItems
                CoreDataStackManager.sharedInstance().saveContext()
                self.itemCollectionView.reloadData()
            })
        }
    }
}