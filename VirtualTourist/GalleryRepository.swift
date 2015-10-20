//
//  GalleryRepository.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 14/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import Foundation
import CoreData
class GalleryRepository {
    
    var gallery: [Photo] = [Photo]()
    var dataFetched: Bool = false
    
    
    func getPhotos(pin: Pin, context: NSManagedObjectContext, completionHandler:(Int, [Photo]?) -> (), errorHandler:(String) -> ()) {
        FlickrClient.sharedInstance().search(pin.latitude, longitude: pin.longitude,
            completionHandler: {
                code, data in
                 dispatch_async(dispatch_get_main_queue(), {
                if let photosDict = data as! NSDictionary!{
                    if let photoDict = photosDict.valueForKey("photos") as? NSDictionary{
                        if let photoArray = photoDict.valueForKey("photo") as? [[String: AnyObject]] {
                            _ = photoArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                               

                                let photo = Photo(pin: pin, dict: dictionary, context: context)
                                return photo
                                
                                
                            }
                        }
                        
                    }
                    
                } else {
                    errorHandler("unable to load photos")
                }
            })
            },
            errorHandler:{
                errorResponse in
                errorHandler(errorResponse)
            }
        )
    }
    
    class func sharedInstance() -> GalleryRepository {
        
        struct Singleton {
            static var sharedInstance = GalleryRepository()
        }
        
        return Singleton.sharedInstance
    }
}