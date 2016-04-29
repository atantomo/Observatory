//
//  SearchSetting.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/23.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

private var filePath : String {

    let manager = NSFileManager.defaultManager()
    let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    return url.URLByAppendingPathComponent("searchSetting").path!
}

class SearchSetting: NSObject, NSCoding {

    var keyword: String
    var category: Category

    override init() {

        keyword = String()
        category = Category.generateAllCategory()
    }

    func encodeWithCoder(archiver: NSCoder) {

        archiver.encodeObject(keyword, forKey: Constants.Archiver.Keyword)
        archiver.encodeObject(category, forKey: Constants.Archiver.Category)
    }

    required init(coder unarchiver: NSCoder) {

        keyword = unarchiver.decodeObjectForKey(Constants.Archiver.Keyword) as! String
        category = unarchiver.decodeObjectForKey(Constants.Archiver.Category) as! Category
        
        super.init()
    }

    func save() {
        
        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }

    class func unarchivedInstance() -> SearchSetting? {

        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? SearchSetting
        } else {
            return nil
        }
    }
}