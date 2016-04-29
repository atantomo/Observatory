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

        keywordLabel.text = searchSetting.keyword
        categoryLabel.text = searchSetting.category.name

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

        let blockerView = BlockerView(frame: view.frame)
        blockerView.backgroundShade.backgroundColor = UIColor.blackColor()
        view.addSubview(blockerView)

        let keyword = searchSetting.keyword
        let catId = String(searchSetting.category.id)

        RakutenClient.sharedInstance().getItem(withKeyword: keyword, genreId: catId) { items, errorMessage in

            self.removeViewAsync(blockerView)

            self.delegate?.searchSettingViewController(self, didRetrieveResult: items)

            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true) {}
            })
        }
        
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