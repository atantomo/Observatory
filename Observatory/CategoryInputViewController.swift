//
//  CategoryInputViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

protocol CategoryInputViewControllerDelegate {

    func categoryInputViewController(categoryInput: CategoryInputViewController, didPickCategory category: Category)
}

class CategoryInputViewController: UITableViewController {

    var searchController: UISearchController!
    var filteredCategories = [Category]()

    var delegate: CategoryInputViewControllerDelegate?

    @IBOutlet weak var categoryTableView: UITableView!

    override func viewDidLoad() {

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        categoryTableView.tableHeaderView = searchController.searchBar

        categoryTableView.delegate = self
        categoryTableView.dataSource = self

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        RakutenClient.sharedInstance().getCategory { result in

            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(categories):

                CategoryData.data = categories
                self.filteredCategories = CategoryData.data

                dispatch_async(dispatch_get_main_queue(), {
                    self.categoryTableView.reloadData()
                })

            case let .Error(err):

                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    // MARK: Workaround to avoid UISearchController-related error
    deinit{

        if let superView = searchController.view {
            superView.removeFromSuperview()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredCategories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let tableCell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        tableCell.textLabel?.text = filteredCategories[indexPath.row].name

        return tableCell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let category = filteredCategories[indexPath.row]
        delegate?.categoryInputViewController(self, didPickCategory: category)

        navigationController?.popViewControllerAnimated(true)
        return
    }
}

extension CategoryInputViewController: UISearchResultsUpdating {

    func updateSearchResultsForSearchController(searchController: UISearchController) {

        guard let lowercaseInputText = searchController.searchBar.text?.lowercaseString else {
            return
        }
        filteredCategories = CategoryData.data.filter { category in

            let noInput = lowercaseInputText.isEmpty

            let lowercaseCategoryText = category.name.lowercaseString
            let isAMatch = lowercaseCategoryText.containsString(lowercaseInputText)
            
            return noInput || isAMatch
        }
        
        categoryTableView.reloadData()
    }
}