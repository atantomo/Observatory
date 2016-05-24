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

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var noImageView: UIView!
    @IBOutlet weak var itemDetailTableView: UITableView!

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var imageFrameView: UIView!
    @IBOutlet weak var frameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var noImageViewHeightConstraint: NSLayoutConstraint!
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

        itemDetailTableView.estimatedRowHeight = 44
        itemDetailTableView.rowHeight = UITableViewAutomaticDimension

        automaticallyAdjustsScrollViewInsets = false

        addGradientView()

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
        frameHeightConstraint.constant = view.frame.width
        noImageViewWidthConstraint.constant = view.frame.width
        noImageViewHeightConstraint.constant = view.frame.width
        tableHeightConstraint.constant = itemDetailTableView.contentSize.height

        setupImage()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "DetailHistorySegue") {

            guard let index = sender as? Int else {
                return
            }
            guard let vc = segue.destinationViewController as? ItemHistoryViewController else {
                return
            }
            vc.selectedDetailType = itemDetails[index].detailType
        }
    }

    @IBAction func closeButtonTapped(sender: UIButton) {

        dismissViewControllerAnimated(true) {}
    }

    @IBAction func goToWebsiteButtonTapped(sender: UIButton) {

        let url = NSURL(string: selectedItem.itemUrl!)!
        UIApplication.sharedApplication().openURL(url)
        return
    }

    private func addGradientView() {

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [
            UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor,
            UIColor.clearColor().CGColor
        ]
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
        imageFrameView.addSubview(gradientView)
    }

    private func setupImage() {

        backgroundView.image = selectedItem.itemImage

        if let localOriginalImage = selectedItem.originalImage {
            itemImageView.image = localOriginalImage
            setImageLayout(itemImageView.image!)

        } else if let localImage = selectedItem.itemImage {

            // fallback (use thumbnail image if original/large image doesn't exist)
            itemImageView.image = localImage
            setImageLayout(localImage)

            guard let imageUrl = selectedItem.originalImageUrl else {
                return
            }

            RakutenClient.sharedInstance().taskForImageWithUrl(imageUrl) { result in

                switch result {
                case let .Success(data):
                    dispatch_async(dispatch_get_main_queue()) {

                        let image = UIImage(data: data)
                        self.selectedItem.originalImage = image
                        self.itemImageView.image = image
                        self.setImageLayout(image!)
                    }
                case .Error:
                    return
                }
            }
        } else {

            noImageView.hidden = false
        }
    }

    private func setImageLayout(image: UIImage) {

        let iW = image.size.width
        let iH = image.size.height
        let fW: CGFloat = view.frame.width
        let fH: CGFloat = view.frame.width

        // if orientation is portrait and image is landscape, set image width to frame's
        // (similar to UIImage's aspect fit behavior)
        if (fH / fW > iH / iW) {
            itemWidthConstraint.constant = fW
            itemHeightConstraint.constant = fW * (iH / iW)
        } else {
            // otherwise, set its height to frame's
            itemHeightConstraint.constant = fH
            itemWidthConstraint.constant = fH * (iW / iH)
        }
    }

    private func configureItemNameCell(cell: ItemNameTableViewCell, withLabel label: String, withData data: String) {

        cell.itemNameTextLabel?.text = data
        cell.selectionStyle = .None
    }

    private func configureTraceableCell(cell: TraceableTableViewCell, withLabel label: String, withData data: [ItemDisplay]) {

        guard let traceableDetail = data.first else {
            return
        }

        switch traceableDetail.direction {
        case .Up:
            cell.changeDirectionContainerWidthConstraint.constant = 28
            cell.changeDirectionIcon.hidden = false
        case .Down:
            cell.changeDirectionContainerWidthConstraint.constant = 28
            cell.changeDirectionIcon.transform = CGAffineTransformMakeScale(1, -1)
            cell.changeDirectionIcon.hidden = false
        default:
            cell.changeDirectionContainerWidthConstraint.constant = 0
            cell.changeDirectionIcon.hidden = true
        }

        cell.traceableTextLabel?.text = label
        cell.traceableDetailLabel?.text = traceableDetail.data
        cell.selectionStyle = .None
    }

    private func configureReviewCell(cell: ReviewTableViewCell, withLabel label: String, withData data: [ItemDisplay]) {

        guard let reviewDetail = data.first as? ReviewDisplay else {
            return
        }

        switch reviewDetail.direction {
        case .Up:
            cell.changeDirectionIconContainerWidthConstraint.constant = 28
            cell.changeDirectionIcon.hidden = false
        case .Down:
            cell.changeDirectionIconContainerWidthConstraint.constant = 28
            cell.changeDirectionIcon.transform = CGAffineTransformMakeScale(1, -1)
            cell.changeDirectionIcon.hidden = false
        default:
            cell.changeDirectionIconContainerWidthConstraint.constant = 0
            cell.changeDirectionIcon.hidden = true
        }

        cell.reviewTextLabel?.text = label
        cell.reviewDetailLabel?.text = reviewDetail.data
        cell.setReviewBarLength(reviewDetail.reviewBarRelativeLength)
        cell.selectionStyle = .None
    }

}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDetails.count
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let itemDetail = itemDetails[indexPath.row]

        switch itemDetail.detailType {
        case let .Static(data):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("StaticDetailCell", forIndexPath: indexPath) as! ItemNameTableViewCell
            configureItemNameCell(cell, withLabel: itemDetail.label, withData: data)
            return cell

        case let .Traceable(data) where data.first is ReviewDisplay:

            let cell = tableView.dequeueReusableCellWithIdentifier("ReviewDetailCell", forIndexPath: indexPath) as! ReviewTableViewCell
            configureReviewCell(cell, withLabel: itemDetail.label, withData: data)
            return cell

        case let .Traceable(data):

            let cell = tableView.dequeueReusableCellWithIdentifier("TraceableDetailCell", forIndexPath: indexPath) as! TraceableTableViewCell
            configureTraceableCell(cell, withLabel: itemDetail.label, withData: data)
            return cell

        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("DetailHistorySegue", sender: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}