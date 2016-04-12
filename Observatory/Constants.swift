//
//  Constants.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

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
            static let Genre = "genreId"
            static let AppId = "applicationId"
        }

        struct JSONResponse {
            static let Items = "Items"
            static let Item = "Item"
            static let Name = "itemName"
            static let Availability = "availability"
            static let ImageUrl = "imageUrl"
            static let ImageUrlS = "smallImageUrls"
            static let ImageUrlM = "mediumImageUrls"
        }
    }
    
}