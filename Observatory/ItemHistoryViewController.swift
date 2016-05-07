//
//  ItemHistoryViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/03.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import CoreData

class ItemHistoryViewController: UITableViewController {

    @IBOutlet weak var itemHistoryTableView: UITableView!

    var selectedDetailType: ItemDetailType!


    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        itemHistoryTableView.dataSource = self
        itemHistoryTableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {

        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.barStyle = .Default
    }

    private func configureCell(cell: UITableViewCell, withItemHistory itemHistory: ItemDetailType, atIndexPath indexPath: NSIndexPath) {

        switch itemHistory {

        case let .Price(price, _):

            let priceHistory = price[indexPath.row]
            cell.textLabel?.text = priceHistory.data
            cell.detailTextLabel?.text =  priceHistory.time

        case let .Review(review, _):

            let reviewHistory = review[indexPath.row]

            guard let reviewCell = cell as? ReviewTableViewCell else {
                return
            }
            reviewCell.reviewTextLabel?.text = reviewHistory.revCount
            reviewCell.reviewDetailLabel?.text = reviewHistory.time
            reviewCell.setReviewBarLength(reviewHistory.revBarLength)

        case let .Availability(availability, _):

            let availabilityHistory = availability[indexPath.row]
            cell.textLabel?.text = availabilityHistory.data
            cell.detailTextLabel?.text =  availabilityHistory.time

        default:
            break
        }
        cell.selectionStyle = .None
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let hist = selectedDetailType else {
            return 0
        }

        switch hist {

        case let .Price(price, _):
            return price.count

        case let .Review(review, _):
            return review.count

        case let .Availability(availability, _):
            return availability.count

        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        guard let hist = selectedDetailType else {
            return UITableViewCell()
        }

        var cell = UITableViewCell()

        switch hist {
        case .Availability, .Price:
            cell = tableView.dequeueReusableCellWithIdentifier("TraceableHistoryCell", forIndexPath: indexPath)

        case .Review:
            cell = tableView.dequeueReusableCellWithIdentifier("ReviewHistoryCell", forIndexPath: indexPath)

        default:
            break
        }
        configureCell(cell, withItemHistory: hist, atIndexPath: indexPath)

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return "RECENT CHANGES"
    }
}