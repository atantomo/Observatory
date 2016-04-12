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

    func getItem(keyword: String, genreId: String, completionHandler: (items: [[String: AnyObject]]?, errorMessage: String?) -> Void) {

        let params = [
            
            Constants.Rakuten.JSONBody.AppId: Constants.Rakuten.ApiKey,
            Constants.Rakuten.JSONBody.Format: "json",
            Constants.Rakuten.JSONBody.Keyword: keyword,
            Constants.Rakuten.JSONBody.Genre: genreId
        ]

        let fileteredParams = params.retainTypeFilter { !$1.isEmpty }

        taskForGETMethod(fileteredParams) { result in

            switch result {

            case let .Success(data):

                guard let items = data[Constants.Rakuten.JSONResponse.Items] as? [[String: AnyObject]] else {
                    
                    print("Could not find Items key in data")
                    completionHandler(items: nil, errorMessage: "Error processing data")
                    return
                }

                completionHandler(items: items, errorMessage: nil)

            case let .Error(error):

                switch error as! ClientError {

                case .Data:
                    completionHandler(items: nil, errorMessage: "Error processing data")

                case .Network:
                    completionHandler(items: nil, errorMessage: "Connection could not be established")
                    
                case .StatusCode(_):
                    completionHandler(items: nil, errorMessage: "Request returned an error response")

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
