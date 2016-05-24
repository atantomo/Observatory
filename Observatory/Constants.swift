//
//  Constants.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

struct Constants {

    struct Rakuten {

        static let BaseUrlSecure = "https://app.rakuten.co.jp/services/api/"
        static let ApiKey = "API_KEY_HERE"

        struct ApiName {

            static let Item = "IchibaItem/"
            static let Genre = "IchibaGenre/"
        }

        struct Methods {

            static let Search = "Search/"
        }

        struct ApiVersion {

            static let Version = "20140222/"
        }

        struct JSONBody {

            static let Format = "format"
            static let Keyword = "keyword"
            static let ItemCode = "itemCode"
            static let GenreId = "genreId"
            static let GenrePath = "genrePath"
            static let PerPage = "hits"
            static let Sort = "sort"
            static let AppId = "applicationId"
        }

        struct JSONResponse {

            static let Items = "Items"
            static let Item = "Item"

            static let Code = "itemCode"
            static let Name = "itemName"
            static let Price = "itemPrice"
            static let Url = "itemUrl"

            static let ImageUrl = "imageUrl"
            static let ImageUrlS = "smallImageUrls"
            static let ImageUrlM = "mediumImageUrls"

            static let Availability = "availability"
            static let ReviewCount = "reviewCount"
            static let ReviewAverage = "reviewAverage"
            static let GenreId = "genreId"

            static let Children = "children"
            static let Child = "child"
            static let GenreName = "genreName"
        }
    }

    struct Archiver {

        static let Keyword = "keyword"
        static let Category = "category"
    }

    struct Size {

        static let Small: CGFloat = 4.0
        static let Medium: CGFloat = 8.0
        static let Large: CGFloat = 16.0
    }
    
}
