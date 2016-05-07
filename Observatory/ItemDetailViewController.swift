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

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var imageFrameView: UIView!
    @IBOutlet weak var frameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var observeButton: UIButton!

    var selectedItem: Item!
    var observedItemCount: Int!
    var itemDetails = [ItemDetail]()

    var sharedContext: NSManagedObjectContext {

        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        itemDetailTableView.estimatedRowHeight = 44
        itemDetailTableView.rowHeight = UITableViewAutomaticDimension

        automaticallyAdjustsScrollViewInsets = false

        addGradientView()
        updateObserveButtonForItem(selectedItem)

        itemDetails = ItemDetail.generateTableContent(selectedItem, context: sharedContext)
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

            switch itemDetail.detailType {

            case .Price:
                let hist = PriceHistory.fetchStoredHistoryForItem(selectedItem, context: sharedContext)
                hist.forEach {
                    $0.readFlg = true
                }

            case .Review:
                let hist = ReviewHistory.fetchStoredHistoryForItem(selectedItem, context: sharedContext)
                hist.forEach {
                    $0.readFlg = true
                }

            case .Availability:
                let hist = AvailabilityHistory.fetchStoredHistoryForItem(selectedItem, context: sharedContext)
                hist.forEach {
                    $0.readFlg = true
                }

            default:
                break
            }
            CoreDataStackManager.sharedInstance().saveContext()

            vc.selectedDetailType = itemDetail.detailType
        }
    }

    @IBAction func closeButtonTapped(sender: UIButton) {

        dismissViewControllerAnimated(true) {}
    }

    @IBAction func observeButtonTapped(sender: UIButton) {

        let maximumObservedItemCount = 3

        if selectedItem.observeFlg {

            let alertCtrl = UIAlertController(title: "Notice", message: "All tracked data for this item will be erased. Would you like to proceed?", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default) { action in

                self.selectedItem.observeFlg = false
                dispatch_async(dispatch_get_main_queue(), {

                    CoreDataStackManager.sharedInstance().saveContext()
                    self.updateObserveButtonForItem(self.selectedItem)
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            alertCtrl.addAction(okAction)
            alertCtrl.addAction(cancelAction)

            self.presentViewController(alertCtrl, animated: true, completion: nil)
        } else{

            guard observedItemCount < maximumObservedItemCount else {

                let alertCtrl = UIAlertController(title: "Notice", message: "You can only add up to \(maximumObservedItemCount) items to your observation list.", preferredStyle: .Alert)

                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

                alertCtrl.addAction(okAction)

                self.presentViewController(alertCtrl, animated: true, completion: nil)
                return
            }

            observedItemCount! += 1

            selectedItem.observeFlg = true
            CoreDataStackManager.sharedInstance().saveContext()

            let alertCtrl = UIAlertController(title: "Notice", message: "Item has been added to your observation list. You can add \(maximumObservedItemCount - observedItemCount) more item(s).", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

            alertCtrl.addAction(okAction)

            self.presentViewController(alertCtrl, animated: true, completion: nil)
            updateObserveButtonForItem(selectedItem)
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

    private func addGradientView() {

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.lightGrayColor().colorWithAlphaComponent(0.7).CGColor, UIColor.clearColor().CGColor]
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
        imageFrameView.addSubview(gradientView)
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

    private func updateObserveButtonForItem(item: Item) {

        if item.observeFlg {
            observeButton.setTitle("Stop observing", forState: .Normal)
            observeButton.backgroundColor = UIColor.lightGrayColor()
        } else {
            observeButton.setTitle("Start observing", forState: .Normal)
            observeButton.backgroundColor = UIColor.darkGrayColor()
        }
    }

    private func configureCell(cell: UITableViewCell, withItemDetail itemDetail: ItemDetail) {
        
        switch itemDetail.detailType {

        case let .ItemName(name):

            guard let itemNameCell = cell as? ItemNameTableViewCell else {
                return
            }

            itemNameCell.itemNameTextLabel?.text = name

        case let .Price(price, shouldNotify):

            guard let traceableCell = cell as? TraceableTableViewCell, let pric = price.first else {
                return
            }

            if shouldNotify {
                traceableCell.notificationContainerWidthConstraint.constant = 28
                traceableCell.notificationIcon.hidden = false
            } else {
                traceableCell.notificationContainerWidthConstraint.constant = 0
                traceableCell.notificationIcon.hidden = true
            }
            traceableCell.traceableTextLabel?.text = itemDetail.label
            traceableCell.traceableDetailLabel?.text = pric.data

        case let .Review(review, shouldNotify):

            guard let reviewCell = cell as? ReviewTableViewCell, let rev = review.first else {
                return
            }

            if shouldNotify {
                reviewCell.notificationContainerWidthConstraint.constant = 28
                reviewCell.notificationIcon.hidden = false
            } else {
                reviewCell.notificationContainerWidthConstraint.constant = 0
                reviewCell.notificationIcon.hidden = true
            }
            reviewCell.reviewTextLabel?.text = itemDetail.label
            reviewCell.reviewDetailLabel?.text = rev.revCount
            reviewCell.setReviewBarLength(rev.revBarLength)

        case let .Availability(availability, shouldNotify):

            guard let traceableCell = cell as? TraceableTableViewCell, let avail = availability.first else {
                return
            }

            if shouldNotify {
                traceableCell.notificationContainerWidthConstraint.constant = 28
                traceableCell.notificationIcon.hidden = false
            } else {
                traceableCell.notificationContainerWidthConstraint.constant = 0
                traceableCell.notificationIcon.hidden = true
            }
            traceableCell.notificationContainerWidthConstraint.constant = shouldNotify ? 28 : 0
            traceableCell.traceableTextLabel?.text = itemDetail.label
            traceableCell.traceableDetailLabel?.text = avail.data
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
            cell = tableView.dequeueReusableCellWithIdentifier("TraceableDetailCell", forIndexPath: indexPath)

        case .Review:
            cell = tableView.dequeueReusableCellWithIdentifier("ReviewDetailCell", forIndexPath: indexPath)
        }
        configureCell(cell, withItemDetail: itemDetail)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("DetailHistorySegue", sender: itemDetails[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}