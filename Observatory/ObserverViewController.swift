//
//  ObserverViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/01.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class ObserverViewController: UIViewController {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var emptyPlaceholderView: UIView!

    var items = [Item]()

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

        if (segue.identifier == "ObserverDetailSegue") {

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

    @IBAction func updateButtonTapped(sender: UIBarButtonItem) {

        items = fetchStoredItems()
        
        let itemCodes = items.map {
            $0.itemCode
        }

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        RakutenClient.sharedInstance().getItem(withItemCodes: itemCodes) { result in

            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(updateItems):

                self.items.forEach { it in
                    it.updateItem(updateItems[it.itemCode]!, context: self.sharedContext)
                }

                dispatch_async(dispatch_get_main_queue(), {

                    self.itemCollectionView.reloadData()
                    CoreDataStackManager.sharedInstance().saveContext()
                })

            case let .Error(err):

                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    private func fetchStoredItems() -> [Item] {

        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "observeFlg == true")
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

extension ObserverViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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

        performSegueWithIdentifier("ObserverDetailSegue", sender: items[indexPath.item])
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}
