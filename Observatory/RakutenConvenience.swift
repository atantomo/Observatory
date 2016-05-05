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

    func getItem(withKeyword keyword: String, genreId: Int, completionHandler: (Result<[[String: AnyObject]]>) -> ()) {

        let params = [

            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.Keyword: keyword,
            Constants.Rakuten.JSONBody.GenreId: String(genreId),
            Constants.Rakuten.JSONBody.PerPage: "30"
        ]

        let filteredParams = params.retainTypeFilter { !$1.isEmpty }

        taskForGETMethod(.Item, params: filteredParams) { result in

            switch result {

            case let .Success(data):

                guard let items = data[Constants.Rakuten.JSONResponse.Items] as? [[String: AnyObject]] else {
                    print("Could not find Items key in data")
                    completionHandler(.Error(ClientError.Data))
                    return
                }

                let item = items.flatMap { $0[Constants.Rakuten.JSONResponse.Item] as? [String: AnyObject] }
                completionHandler(.Success(item))

            case let .Error(error):
                
                completionHandler(.Error(error))
            }
        }
    }

    func getItem(withItemCodes itemCodes: [String], completionHandler: (Result<[String: [String: AnyObject]]>) -> ()) {

        var compoundItems = [String: [String: AnyObject]]()
        var resultCount = 0
        itemCodes.forEach { itemCode in

            let params = [

                Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
                Constants.Rakuten.JSONBody.Format: "json",
                Constants.Rakuten.JSONBody.ItemCode: itemCode,
                Constants.Rakuten.JSONBody.PerPage: "1"
            ]

            taskForGETMethod(.Item, params: params) { result in

                resultCount += 1

                switch result {

                case let .Success(data):

                    guard let items = data[Constants.Rakuten.JSONResponse.Items] as? [[String: AnyObject]] else {
                        print("Could not find Items key in data")
                        completionHandler(.Error(ClientError.Data))
                        break
                    }

                    let item = items.flatMap { $0[Constants.Rakuten.JSONResponse.Item] as? [String: AnyObject] }

                    let itemCode = item.first!["itemCode"] as! String
                    compoundItems[itemCode] = item.first!

                    if resultCount == itemCodes.count {


                        print(compoundItems)
                        completionHandler(.Success(compoundItems))
                        break
                    }

                case let .Error(error):
                    
                    completionHandler(.Error(error))
                    break
                }
            }
        }
    }

    func getCategory(completionHandler: (Result<[Category]>) -> ()) {

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
                    completionHandler(.Error(ClientError.Data))
                    return
                }

                let categoryDict = categoriesDict.flatMap { $0[Constants.Rakuten.JSONResponse.Child] as? [String: AnyObject] }

                var categories = [Category]()
                categories.append(Category.generateAllCategory())
                categories.appendContentsOf(Category.extractResult(categoryDict))

                completionHandler(.Success(categories))

            case let .Error(error):

                completionHandler(.Error(error))
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
