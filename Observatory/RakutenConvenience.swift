//
//  RakutenConvenience.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

extension Dictionary {

    func retainTypeFilter(includeElement: Element -> Bool) -> Dictionary {

        let filteredArray = self.filter { key, value in includeElement((key, value)) }

        // convert the resulting tuple back into dictionary
        var filteredDictionary = Dictionary()
        filteredArray.forEach { result in
            filteredDictionary[result.0] = result.1
        }

        return filteredDictionary
    }
}


extension RakutenClient {

    func getItem(withKeyword keyword: String, genreId: String, completionHandler: (items: [[String: AnyObject]]?, errorMessage: String?) -> Void) {

        let params = [
            
            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.Keyword: keyword,
            Constants.Rakuten.JSONBody.GenreId: genreId,
            Constants.Rakuten.JSONBody.PerPage: "30"
        ]

        let filteredParams = params.retainTypeFilter { !$1.isEmpty }
        print(filteredParams)

        taskForGETMethod(.Item, params: filteredParams) { result in

            switch result {

            case let .Success(data):

                guard let items = data[Constants.Rakuten.JSONResponse.Items] as? [[String: AnyObject]] else {
                    
                    print("Could not find Items key in data")
                    completionHandler(items: nil, errorMessage: "Error processing data")
                    return
                }

                let item = items.flatMap { $0[Constants.Rakuten.JSONResponse.Item] as? [String: AnyObject] }

                completionHandler(items: item, errorMessage: nil)

            case let .Error(error):

                switch error as! ClientError {

                case .Data:
                    completionHandler(items: nil, errorMessage: "Error processing data")

                case .Connectivity:
                    completionHandler(items: nil, errorMessage: "Connection could not be established")
                    
                case .StatusCode(_):
                    completionHandler(items: nil, errorMessage: "Request returned an error response")

                }
            }
        }
    }

    func getCategory(completionHandler: (categories: [Category]?, errorMessage: String?) -> Void) {

        let params = [

            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.GenreId: "0",
            Constants.Rakuten.JSONBody.GenrePath: "0"
        ]

        let fileteredParams = params.retainTypeFilter { !$1.isEmpty }

        taskForGETMethod(.Genre, params: fileteredParams) { result in

            switch result {

            case let .Success(data):

                guard let categoriesDict = data[Constants.Rakuten.JSONResponse.Children] as? [[String: AnyObject]] else {

                    print("Could not find Children key in data")
                    completionHandler(categories: nil, errorMessage: "Error processing data")
                    return
                }

                let categoryDict = categoriesDict.flatMap { $0[Constants.Rakuten.JSONResponse.Child] as? [String: AnyObject] }

                var categories = [Category]()
                categories.append(Category.generateAllCategory())
                categories.appendContentsOf(Category.extractResult(categoryDict))

                completionHandler(categories: categories, errorMessage: nil)

            case let .Error(error):

                switch error as! ClientError {

                case .Data:
                    completionHandler(categories: nil, errorMessage: "Error processing data")

                case .Connectivity:
                    completionHandler(categories: nil, errorMessage: "Connection could not be established")

                case .StatusCode(_):
                    completionHandler(categories: nil, errorMessage: "Request returned an error response")
                    
                }
            }
        }
    }

    private func pickRandom<T>(collection: [T], withDesiredCount desiredCount: Int) -> [T] {

        var collection = collection
        // make sure that the desired count does not exceed the real count
        let resultCount = min(collection.count, desiredCount)

        var randomizedCollection = [T]()

        for _ in 0 ..< resultCount {

            let randomIndex = Int(arc4random()) % collection.count
            randomizedCollection.append(collection[randomIndex])

            // remove current element from sample to ensure the element in the next loop is unique
            collection.removeAtIndex(randomIndex)
        }
        
        return randomizedCollection
    }
    
}
