//
//  KeywordInputViewController.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/19.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

protocol KeywordInputViewControllerDelegate {

    func keywordInputViewController(keywordInput: KeywordInputViewController, didInputKeyword keyword: String?)
}

class KeywordInputViewController: UITableViewController {

    @IBOutlet weak var keywordTextField: InsetTextField!

    var keyword = String()
    var delegate: KeywordInputViewControllerDelegate?

    override func viewDidLoad() {

        keywordTextField.text = keyword
        keywordTextField.becomeFirstResponder()
        keywordTextField.delegate = self
    }
}

extension KeywordInputViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {

        delegate?.keywordInputViewController(self, didInputKeyword: textField.text)
    }
}