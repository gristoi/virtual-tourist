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
                if let photosDict = data as! NSDictionary!{
                    if let photoDict = photosDict.valueForKey("photos") as? NSDictionary{
                        if let photoArray = photoDict.valueForKey("photo") as? [[String: AnyObject]] {
                            _ = photoArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                                let photo = Photo(pin: pin, dict: dictionary, context: context)
                                print(dictionary)
                                return photo
                            }
                            //CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                } else {
                    errorHandler("unable to load photos")
                }
            },
            errorHandler:{
                errorResponse in
                print(errorResponse)
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