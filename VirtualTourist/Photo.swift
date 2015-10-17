//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 09/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import Foundation
import CoreData
@objc(Photo)
class Photo: NSManagedObject {

    @NSManaged var srcUrl: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin , dict: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        srcUrl = dict["srcUrl"] as? String
        self.pin =  pin
        try! context.save()
    }

}
