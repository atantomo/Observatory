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

    private func configureTraceableCell(cell: TraceableTableViewCell, withData data: [ItemDisplay], atIndexPath indexPath: NSIndexPath) {

        let traceableDetail = data[indexPath.row]

        switch traceableDetail.direction {
        case .Up:
            cell.changeDirectionIcon.hidden = false
        case .Down:
            cell.changeDirectionIcon.transform = CGAffineTransformMakeScale(1, -1)
            cell.changeDirectionIcon.hidden = false
        default:
            cell.changeDirectionIcon.hidden = true
        }

        cell.traceableTextLabel?.text = traceableDetail.data
        cell.traceableDetailLabel?.text = traceableDetail.time
    }

    private func configureReviewCell(cell: ReviewTableViewCell, withData data: [ItemDisplay], atIndexPath indexPath: NSIndexPath) {

        guard let reviewDetail = data[indexPath.row] as? ReviewDisplay else {
            return
        }

        switch reviewDetail.direction {
        case .Up:
            cell.changeDirectionIcon.hidden = false
        case .Down:
            cell.changeDirectionIcon.transform = CGAffineTransformMakeScale(1, -1)
            cell.changeDirectionIcon.hidden = false
        default:
            cell.changeDirectionIcon.hidden = true
        }

        cell.reviewTextLabel?.text = reviewDetail.data
        cell.reviewDetailLabel?.text = reviewDetail.time
        cell.setReviewBarLength(reviewDetail.reviewBarRelativeLength)
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch selectedDetailType! {
        case let .Traceable(data):
            return data.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch selectedDetailType! {
        case let .Traceable(data) where data.first is ReviewDisplay:

            let cell = tableView.dequeueReusableCellWithIdentifier("ReviewHistoryCell", forIndexPath: indexPath) as! ReviewTableViewCell
            configureReviewCell(cell, withData: data, atIndexPath: indexPath)
            return cell

        case let .Traceable(data):

            let cell = tableView.dequeueReusableCellWithIdentifier("TraceableHistoryCell", forIndexPath: indexPath)  as! TraceableTableViewCell
            configureTraceableCell(cell, withData: data, atIndexPath: indexPath)
            return cell

        default:
            return UITableViewCell()
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return "RECENT CHANGES"
    }
}