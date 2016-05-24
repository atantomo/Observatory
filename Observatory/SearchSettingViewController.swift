//
//  SearchSettingViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

protocol SearchSettingViewControllerDelegate {

    func searchSettingViewController(searchSetting: SearchSettingViewController, didRetrieveResult result: [String: [String: AnyObject]]?)
}

class SearchSettingViewController: UITableViewController {

    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    var delegate: SearchSettingViewControllerDelegate?

    var searchSetting = SearchSetting()
    var keywordCache = String()
    var categoryCache = Category.generateAllCategory()

    override func viewDidLoad() {

        setKeywordData(searchSetting.keyword)
        setCategoryData(searchSetting.category)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "KeywordInput") {

            guard let vc = segue.destinationViewController as? KeywordInputViewController else {
                return
            }
            vc.keyword = keywordCache
            vc.delegate = self
        }

        if (segue.identifier == "CategoryInput") {

            guard let vc = segue.destinationViewController as? CategoryInputViewController else {
                return
            }
            vc.delegate = self
        }
    }

    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {

        dismissViewControllerAnimated(true) {}
    }

    @IBAction func saveBarButtonTapped(sender: UIBarButtonItem) {

        if (GroupedItemData.data.flatMap { $0 }).isEmpty {
            startSearchRequest(nil)

        } else {
            let alertCtrl = UIAlertController(title: "Warning", message: "Performing a new search will remove all existing data. Would you like to proceed?", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default, handler: startSearchRequest)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            alertCtrl.addAction(okAction)
            alertCtrl.addAction(cancelAction)

            self.presentViewController(alertCtrl, animated: true, completion: nil)
        }
    }

    private func startSearchRequest(action: UIAlertAction?) {

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        let keyword = keywordCache
        let catId = categoryCache.id

        RakutenClient.sharedInstance().getIndexedRawItem(withKeyword: keyword, genreId: catId) { result in

            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(items):

                self.searchSetting.keyword = self.keywordCache
                self.searchSetting.category = self.categoryCache
                self.searchSetting.save()

                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.searchSettingViewController(self, didRetrieveResult: items)
                    self.dismissViewControllerAnimated(true) {}
                })
            case let .Error(err):

                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    private func setKeywordData(string: String) {

        guard !string.isEmpty else {
            keywordLabel.text = "Not set"
            return
        }
        keywordLabel.text = string
        keywordCache = string
    }

    private func setCategoryData(category: Category) {

        categoryLabel.text = category.name
        categoryCache = category
    }

}

extension SearchSettingViewController: KeywordInputViewControllerDelegate {

    func keywordInputViewController(keywordInput: KeywordInputViewController, didInputKeyword keyword: String) {

        if !keyword.isEmpty {
            keywordLabel.text = keyword

        } else {
            keywordLabel.text = "Not set"
        }
        keywordCache = keyword
    }
}

extension SearchSettingViewController: CategoryInputViewControllerDelegate {

    func categoryInputViewController(categoryInput: CategoryInputViewController, didPickCategory category: Category) {

        categoryLabel.text = category.name
        categoryCache = category
    }
}