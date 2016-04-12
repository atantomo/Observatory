//
//  ImageCache.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class ImageCache {

    private var inMemoryCache = NSCache()

    func imageWithIdentifier(identifier: String?) -> UIImage? {

        guard let identifier = identifier where identifier != "" else {
            return nil
        }

        let path = pathForIdentifier(identifier)

        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }

        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }

        return nil
    }

    func storeImage(image: UIImage?, withIdentifier identifier: String) {

        let path = pathForIdentifier(identifier)

        guard let image = image else {

            inMemoryCache.removeObjectForKey(path)

            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {
                print("Could not remove file in path: \(path)")
            }
            return
        }

        inMemoryCache.setObject(image, forKey: path)

        let data = UIImageJPEGRepresentation(image, 0.9)
        data?.writeToFile(path, atomically: true)
    }

    func pathForIdentifier(identifier: String) -> String {

        let documentsDirectoryUrl: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullUrl = documentsDirectoryUrl.URLByAppendingPathComponent(identifier)

        return fullUrl.path!
    }
}
