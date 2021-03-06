//
//  RakutenClient.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/04/10.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

enum Result<T> {

    case Success(T)
    case Error(ErrorType)
}

enum HttpStatusCode {

    case Success
    case BadRequest
    case Forbidden
    case NotFound
    case Unknown

    init(code: Int) {

        switch code {
        case 200..<300:
            self = .Success
        case 400:
            self = .BadRequest
        case 403:
            self = .Forbidden
        case 404:
            self = .NotFound
        default:
            self = .Unknown
        }
    }
}


final class RakutenClient: NSObject {

    enum ClientError: ErrorType {

        case EmptyResult
        case DataProcessing
        case NetworkConnectivity
        case StatusCode(HttpStatusCode)
    }

    enum InputError: ErrorType {

        case Invalid
        case MissingParameter
    }

    enum Api {

        case Item
        case Genre
    }

    var session: NSURLSession

    private var itemApiBasePath: String {

        return Constants.Rakuten.ApiName.Item + Constants.Rakuten.Methods.Search + Constants.Rakuten.ApiVersion.Version
    }

    private var genreApiBasePath: String {

        return Constants.Rakuten.ApiName.Genre + Constants.Rakuten.Methods.Search + Constants.Rakuten.ApiVersion.Version
    }

    override init() {

        session = NSURLSession.sharedSession()
        super.init()
    }

    class func sharedInstance() -> RakutenClient {

        struct Singleton {
            static var sharedInstance = RakutenClient()
        }

        return Singleton.sharedInstance
    }

    struct Caches {
        
        static let imageCache = ImageCache()
    }

    static func generateErrorMessage(error: ErrorType) -> String? {

        if let err = error as? ClientError {

            switch err {
            case .NetworkConnectivity:
                return "Network connection could not be established"
            case .DataProcessing:
                return "There was an error in processing data"
            case .StatusCode:
                return "Request returned an error response"
            case .EmptyResult:
                return "Could not find any matching item. Please try another keyword or category"
            }
        }

        if let err = error as? InputError {

            switch err {
            case .Invalid:
                return "Please input a keyword more than 1 character long"
            case .MissingParameter:
                return "Please input either a keyword or category"
            }
        }
        return nil
    }

    func taskForGETMethod(api: Api, params: [String: AnyObject], completionHandler: (Result<NSDictionary>) -> ()) -> NSURLSessionDataTask {

        var apiBasePath = String()

        switch api {
        case .Item:
            apiBasePath = itemApiBasePath
        case .Genre:
            apiBasePath = genreApiBasePath
        }

        let urlString = Constants.Rakuten.BaseUrlSecure + apiBasePath + escapedParameters(params)

        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"

        let task = session.dataTaskWithRequest(request) { data, response, error in

            guard self.hasValidResponse(data, response: response, error: error, completionHandler: completionHandler) else {
                return
            }

            var parsedData = NSDictionary()
            do {

                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary

            } catch {

                print("Failed parsing JSON data")
                completionHandler(.Error(ClientError.DataProcessing))
                return
            }

            completionHandler(.Success(parsedData))

        }
        task.resume()

        return task
    }

    func taskForImageWithUrl(urlString: String, completionHandler: (Result<NSData>) -> ()) -> NSURLSessionTask {

        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) { data, response, error in

            guard self.hasValidResponse(data, response: response, error: error, completionHandler: completionHandler) else {
                return
            }

            completionHandler(.Success(data!))
        }

        task.resume()

        return task
    }

    private func hasValidResponse<T>(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (Result<T>) -> ()) -> Bool {

        guard error == nil else {

            print("Request returned an error: \(error)")
            completionHandler(.Error(ClientError.NetworkConnectivity))
            return false
        }

        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {

            print("Status code is nil")
            completionHandler(.Error(ClientError.DataProcessing))
            return false
        }

        guard HttpStatusCode(code: statusCode) == .Success else {

            print("Request returned status code: \(statusCode)")
            let errorStatusCode = HttpStatusCode(code: statusCode)
            completionHandler(.Error(ClientError.StatusCode(errorStatusCode)))
            return false
        }

        guard data != nil else {

            print("Request returned no data")
            completionHandler(.Error(ClientError.DataProcessing))
            return false
        }

        return true
    }

    private func escapedParameters(parameters: [String: AnyObject]) -> String {

        if parameters.isEmpty {
            return ""
        }

        var keyValuePairs = [String]()

        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            keyValuePairs.append(key + "=" + "\(escapedValue!)")
        }
        
        return "?\(keyValuePairs.joinWithSeparator("&"))"
        
    }
}
