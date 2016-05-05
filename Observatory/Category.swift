//
//  Category.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/20.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

class Category : NSObject, NSCoding {

    static let allCategoryId = 0

    var id = Int()
    var name = String()


    init(dictionary: [String : AnyObject]) {

        id = dictionary[Constants.Rakuten.JSONResponse.GenreId] as! Int
        name = dictionary[Constants.Rakuten.JSONResponse.GenreName] as! String
    }

    static func generateAllCategory() -> Category {

        let all: [String : AnyObject] = [
            Constants.Rakuten.JSONResponse.GenreId: allCategoryId,
            Constants.Rakuten.JSONResponse.GenreName: "All"
        ]
        return Category(dictionary: all)
    }

    static func extractResult(results: [[String : AnyObject]]) -> [Category] {

        var genres = [Category]()

        for result in results {
            genres.append(Category(dictionary: result))
        }
        
        return genres
    }

    func encodeWithCoder(archiver: NSCoder) {

        archiver.encodeInteger(id, forKey: Constants.Rakuten.JSONResponse.GenreId)
        archiver.encodeObject(name, forKey: Constants.Rakuten.JSONResponse.GenreName)
    }

    required init(coder unarchiver: NSCoder) {
        super.init()

        id = unarchiver.decodeIntegerForKey(Constants.Rakuten.JSONResponse.GenreId)
        name = unarchiver.decodeObjectForKey(Constants.Rakuten.JSONResponse.GenreName) as! String
    }

}

class CategoryData {

    static var data: [Category] = Array()
}
