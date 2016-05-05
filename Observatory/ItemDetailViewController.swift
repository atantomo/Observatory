//
//  ItemDetailViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/24.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemDetailTableView: UITableView!

    @IBOutlet weak var imageFrameView: UIView!
    @IBOutlet weak var frameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!

    var selectedItem: Item!
    var itemDetails = [ItemDetail]()

    var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        automaticallyAdjustsScrollViewInsets = false

        itemDetails = ItemDetail.generateTableContent(selectedItem)
        itemDetailTableView.delegate = self
        itemDetailTableView.dataSource = self
        itemDetailTableView.scrollEnabled = false
        itemDetailTableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBar.hidden = true
        navigationController?.navigationBar.barStyle = .Black
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        contentWidthConstraint.constant = view.frame.width
        frameHeightConstraint.constant = imageFrameView.frame.width
        tableHeightConstraint.constant = itemDetailTableView.contentSize.height

        if let localImage = selectedItem.itemImage {
            itemImageView.image = localImage
            setImageLayout(itemImageView.image!)

        } else {

            guard let imageUrl = selectedItem.imageUrl else {
                itemImageView.image = nil
                return
            }

            let placeholderView = PlaceholderView(frame: CGRectMake(0, 0, imageFrameView.frame.width, imageFrameView.frame.height))
            imageFrameView.addSubview(placeholderView)

            RakutenClient.sharedInstance().taskForImageWithUrl(imageUrl) { result in

                self.removeViewAsync(placeholderView)

                switch result {
                case let .Success(data):
                    dispatch_async(dispatch_get_main_queue()) {

                        let image = UIImage(data: data)
                        self.itemImageView.image = image
                        self.setImageLayout(image!)
                    }
                case .Error:
                    self.itemImageView.image = nil
                    return
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "DetailHistorySegue") {

            guard let itemDetail = sender as? ItemDetail else {
                return
            }

            guard let vc = segue.destinationViewController as? ItemHistoryViewController else {
                return
            }

            vc.selectedDetailType = itemDetail.detailType
        }
    }

    @IBAction func closeButtonTapped(sender: UIButton) {

        dismissViewControllerAnimated(true) {}
    }

    @IBAction func observeButtonTapped(sender: UIButton) {

        if selectedItem.observeFlg {

            let alertCtrl = UIAlertController(title: "Notice", message: "All tracked data for this item will be erased. Would you like to proceed?", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default) { action in

                self.selectedItem.observeFlg = false
                dispatch_async(dispatch_get_main_queue(), {

                    CoreDataStackManager.sharedInstance().saveContext()
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            alertCtrl.addAction(okAction)
            alertCtrl.addAction(cancelAction)

            self.presentViewController(alertCtrl, animated: true, completion: nil)
        } else{

            selectedItem.observeFlg = true
            CoreDataStackManager.sharedInstance().saveContext()
        }
//        let availabilityHist = AvailabilityHistory(availability: selectedItem.availability, context: self.sharedContext)
//        availabilityHist.item = selectedItem
//        let priceHist = PriceHistory(itemPrice: selectedItem.itemPrice, context: self.sharedContext)
//        priceHist.item = selectedItem
//        let reviewHist = ReviewHistory(count: selectedItem.reviewCount, average: selectedItem.reviewAverage, context: self.sharedContext)
//        reviewHist.item = selectedItem

    }

    @IBAction func goToWebsiteButtonTapped(sender: UIButton) {

        let url = NSURL(string: selectedItem.itemUrl!)!
        UIApplication.sharedApplication().openURL(url)
        return
    }

    private func setImageLayout(image: UIImage) {

        let iW = image.size.width
        let iH = image.size.height
        let fW = imageFrameView.frame.size.width
        let fH = imageFrameView.frame.size.height

        // if orientation is portrait and meme is landscape, set meme width to canvas'
        // (similar to UIImage's aspect fit behavior)
        if (fH / fW > iH / iW) {
            itemWidthConstraint.constant = imageFrameView.frame.size.width
            itemHeightConstraint.constant = imageFrameView.frame.size.width * (iH / iW)
        } else {
            // otherwise, set meme height to canvas'
            itemWidthConstraint.constant = imageFrameView.frame.size.height
            itemHeightConstraint.constant = imageFrameView.frame.size.height * (iW / iW)
        }
    }

    private func configureCell(cell: UITableViewCell, withItemDetail itemDetail: ItemDetail) {
        
        switch itemDetail.detailType {

        case let .ItemName(name):

            cell.textLabel?.text = name

        case let .Price(price, shouldNotify):

            guard let pric = price.first else {
                return
            }

            cell.textLabel?.text = itemDetail.label
            cell.detailTextLabel?.text = pric.data

        case let .Review(review, shouldNotify):

            guard let reviewCell = cell as? ReviewTableViewCell else {
                return
            }

            guard let rev = review.first else {
                return
            }

            reviewCell.reviewTextLabel?.text = itemDetail.label
            reviewCell.reviewDetailLabel?.text = rev.revCount

            reviewCell.reviewBarWidthConstraint.constant = CGFloat(rev.revBarLength) / 5.0 * reviewCell.reviewBarView.frame.width
            reviewCell.reviewBarView.maskView = UIImageView(image: UIImage(named: "star"))

        case let .Availability(availability, shouldNotify):

            guard let avail = availability.first else {
                return
            }

            cell.textLabel?.text = itemDetail.label
            cell.detailTextLabel?.text = avail.data
        }
        cell.selectionStyle = .None
    }

}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDetails.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let itemDetail = itemDetails[indexPath.row]

        var cell = UITableViewCell()
        switch itemDetail.detailType {
        case .ItemName:
            cell = tableView.dequeueReusableCellWithIdentifier("StaticDetailCell", forIndexPath: indexPath)

        case .Price, .Availability:
            cell = tableView.dequeueReusableCellWithIdentifier("TrackableDetailCell", forIndexPath: indexPath)

        case .Review:
            cell = tableView.dequeueReusableCellWithIdentifier("ReviewDetailCell", forIndexPath: indexPath) as! ReviewTableViewCell
        }
        configureCell(cell, withItemDetail: itemDetail)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("DetailHistorySegue", sender: itemDetails[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}