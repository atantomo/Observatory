//
//  RakutenConvenience.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

extension RakutenClient {

    func getIndexedRawItem(withKeyword keyword: String, genreId: Int, completionHandler: (Result<[String: [String: AnyObject]]>) -> ()) {

        let params = [

            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.Keyword: keyword,
            Constants.Rakuten.JSONBody.GenreId: String(genreId),
            Constants.Rakuten.JSONBody.PerPage: "30",
            Constants.Rakuten.JSONBody.Sort: "standard"
        ]

        let inputError = validateSearchParamerter(params)
        guard inputError == nil else {

            completionHandler(.Error(inputError!))
            return
        }

        taskForGETMethod(.Item, params: params) { result in

            switch result {

            case let .Success(data):

                guard let wholeRawItems = data[Constants.Rakuten.JSONResponse.Items] as? [[String: AnyObject]] else {

                    print("Could not find 'Items' key in data")
                    completionHandler(.Error(ClientError.DataProcessing))
                    return
                }

                let rawItems = wholeRawItems.flatMap { $0[Constants.Rakuten.JSONResponse.Item] as? [String: AnyObject] }

                guard !rawItems.isEmpty else {
                    completionHandler(.Error(ClientError.EmptyResult))
                    return
                }

                var indexedRawItems = [String: [String: AnyObject]]()
                rawItems.forEach { rawItem in
                    if let itemCode = rawItem[Constants.Rakuten.JSONResponse.Code] as? String {
                        indexedRawItems[itemCode] = rawItem
                    }
                }

                completionHandler(.Success(indexedRawItems))

            case let .Error(error):
                
                completionHandler(.Error(error))
            }
        }
    }

    private func validateSearchParamerter(params: [String: String]) -> InputError? {

        if let keyword = params[Constants.Rakuten.JSONBody.Keyword],
            let category = params[Constants.Rakuten.JSONBody.GenreId] {

            let trimmedKeyword = keyword.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            let keywordIsValid = trimmedKeyword.isEmpty || trimmedKeyword.characters.count > 1

            guard keywordIsValid else {
                return .Invalid
            }

            let categorySelected = category != String(Category.allCategoryId)
            let parametersPresent = !trimmedKeyword.isEmpty || categorySelected

            guard parametersPresent else {
                return .MissingParameter
            }
            return nil
        }
        return nil
    }

    func getCategory(completionHandler: (Result<[Category]>) -> ()) {

        let params = [

            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.GenreId: "0",
            Constants.Rakuten.JSONBody.GenrePath: "0"
        ]

        taskForGETMethod(.Genre, params: params) { result in

            switch result {

            case let .Success(data):

                guard let wholeRawCategories = data[Constants.Rakuten.JSONResponse.Children] as? [[String: AnyObject]] else {

                    print("Could not find 'Children' key in data")
                    completionHandler(.Error(ClientError.DataProcessing))
                    return
                }

                let rawCategories = wholeRawCategories.flatMap { $0[Constants.Rakuten.JSONResponse.Child] as? [String: AnyObject] }

                var categories = [Category]()

                // this is for appending 'All' category, NOT 'all categories'
                categories.append(Category.generateAllCategory())
                categories.appendContentsOf(Category.extractResult(rawCategories))

                completionHandler(.Success(categories))

            case let .Error(error):

                completionHandler(.Error(error))
            }
        }
    }
}
