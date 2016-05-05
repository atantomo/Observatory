//
//  SearchSettingViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

protocol SearchSettingViewControllerDelegate {

    func searchSettingViewController(searchSetting: SearchSettingViewController, didRetrieveResult result: [[String: AnyObject]]?)
}

class SearchSettingViewController: UITableViewController {


    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!


    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    var delegate: SearchSettingViewControllerDelegate?

    var searchSetting = SearchSetting()

    override func viewDidLoad() {

        setKeywordLabelText(searchSetting.keyword)
        setCategoryLabelText(searchSetting.category.name)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "KeywordInput") {

            guard let vc = segue.destinationViewController as? KeywordInputViewController else {
                return
            }
            
            vc.keyword = searchSetting.keyword
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

        let loaderView = LoaderView(frame: view.frame)
        view.addSubview(loaderView)

        let keyword = searchSetting.keyword
        let catId = searchSetting.category.id

        RakutenClient.sharedInstance().getItem(withKeyword: keyword, genreId: catId) { result in
            
            self.removeViewAsync(loaderView)

            switch result {
            case let .Success(items):

                self.delegate?.searchSettingViewController(self, didRetrieveResult: items)
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true) {}
                })
            case let .Error(err):

                let msg = RakutenClient.generateErrorMessage(err)
                self.displayErrorAsync(msg)
            }
        }
    }

    private func setKeywordLabelText(string: String) {

        guard !string.isEmpty else {
            keywordLabel.text = "Not set"
            return
        }
        keywordLabel.text = string
    }

    private func setCategoryLabelText(string: String) {

        categoryLabel.text = string
    }

}

extension SearchSettingViewController: KeywordInputViewControllerDelegate {

    func keywordInputViewController(keywordInput: KeywordInputViewController, didInputKeyword keyword: String?) {

        guard let searchWord = keyword where !searchWord.isEmpty else {
            keywordLabel.text = "Not set"
            return
        }

        keywordLabel.text = searchWord

        searchSetting.keyword = searchWord
        searchSetting.save()
    }
}

extension SearchSettingViewController: CategoryInputViewControllerDelegate {

    func categoryInputViewController(categoryInput: CategoryInputViewController, didPickCategory category: Category) {

        categoryLabel.text = category.name

        searchSetting.category = category
        searchSetting.save()
    }
}