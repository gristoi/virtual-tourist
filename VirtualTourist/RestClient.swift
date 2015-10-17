//
//  BaseApi.swift
//  on the map
//
//  Created by Ian Gristock on 01/09/2015.
//  Copyright (c) 2015 Ian Gristock. All rights reserved.
//

import Foundation

protocol HttpClient {
    func getBaseUrl() -> String
}

class RestClient : NSObject, HttpClient{
    
    // Session object
    var session: NSURLSession
    var headers: [String:AnyObject] = ["application/json": ["Accept","Content-Type"]]
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func get(params:[String:AnyObject]? = nil, success:(Int, AnyObject!) -> () = {_,_ in}, failure:(String) -> () = {_ in}) {
        
        executeRequest("GET", parameters: params, success: success, failure: failure)
    }
    
    func executeRequest(verb: String!, parameters: [String:AnyObject]? , success:(Int, AnyObject!) -> (), failure:(String) -> ()) {
        
        let urlString = "\(getBaseUrl())\(RestClient.escapedParameters(parameters!))"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = verb
        // build up the headers
        for (key, field) in headers {
            
            // check if it is a flat key pair
            if let str = field as?String {
                request.addValue(key, forHTTPHeaderField: str)
            }
            //check if the value is a dict
            if let array = field as? NSArray {
                for (value) in array {
                    request.addValue(key, forHTTPHeaderField: value as! String)
                }
            }
        }
        if parameters != nil {
            
            // Generate the body using the passed json body
            do{
                 request.HTTPBody  = try NSJSONSerialization.dataWithJSONObject(parameters!, options: [])
            } catch _ {
                
            }
           
        }
        // Send request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Network error
                failure("Unable to connect to the network")
                return
            }
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String : AnyObject]
                
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                success(statusCode, json)
                
            } catch let jsonError as NSError {
                print(jsonError)
            }
            
            
            
        }
        task.resume()
    }
    
    func getBaseUrl() ->String {
        fatalError("Cannot impliment get base url in base class");
    }
    
    /** Helper function: Given a dictionary of parameters, convert it to a string for a url **/
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            _ = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: .LiteralSearch, range: nil)
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
}

extension RestClient {
    
    struct HTTPResponseCodes {
        static let OK = 200
        static let BAD_CREDENTIALS = 403
        static let FATAL = 500
    }
}