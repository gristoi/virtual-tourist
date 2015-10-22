//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 09/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class Photo: NSManagedObject {

    @NSManaged var srcUrl: String
    @NSManaged var pin: Pin
    @NSManaged var id: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin , dict: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        srcUrl = dict["url_m"] as! String
        id = dict["id"] as! String
        self.pin =  pin
        try! context.save()
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(self.id)
        }
    }
    
    override func prepareForDeletion() {
            FlickrClient.Caches.imageCache.storeImage(nil, withIdentifier: self.id)
        }

}
