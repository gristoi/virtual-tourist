//
//  ParseClient.swift
//  on the map
//
//  Created by Ian Gristock on 01/09/2015.
//  Copyright (c) 2015 Ian Gristock. All rights reserved.
//

import Foundation

class FlickrClient: RestClient  {
    
    var currentPage: Int = 1
    
    override init() {
        super.init()
    }
    
    
    override func getBaseUrl() -> String {
        return Constants.BaseURL;
    }
    
    func search(latitude: Double,longitude: Double, completionHandler:(Int, AnyObject?) -> (), errorHandler:(String) -> ()) {
        
        let params:[String:AnyObject] = [
            "lat": latitude,
            "lon": longitude,
            "method": FlickrClient.Methods.Search,
            "api_key": FlickrClient.Constants.FlickrApiKey,
            "extras": FlickrClient.Constants.Extras,
            "per_page": FlickrClient.Constants.PerPage,
            "format": FlickrClient.Constants.Format,
            "nojsoncallback": FlickrClient.Constants.NoJson,
            "page": Int(currentPage)]
        
        get(params,
            success: {
                responseCode, data in
                if let error = data!["error"] as? String{
                    errorHandler(error)
                } else {
                    completionHandler(responseCode, data)
                }
                ++self.currentPage
            },
            failure:{
                errorResponse in
                errorHandler(errorResponse)
            }
        )
    }
    
    func getImage(imageSrc: String, completionHandler:(Int, NSData) -> (), errorHandler:(String) -> ()) -> NSURLSessionTask {
        let url = NSURL(string: imageSrc)!
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let _ = downloadError {
                errorHandler("failed to download image")
            } else {
                completionHandler(200, data!)
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
}

extension FlickrClient {
    
    struct Constants {
        
        // URL
        static let BaseURL : String = "https://api.flickr.com/services/rest"
        static let Extras: String = "url_m"
        static let FlickrApiKey: String = "363e853c336f873afd8299b13c2c0eba"
        static let PerPage: Int = 24
        static let NoJson: Int = 1
        static let Format = "json"
    }
    
    struct Methods {
        static let Search: String = "flickr.photos.search"
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}