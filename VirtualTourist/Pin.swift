//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 09/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
        static let CreationDate = "CreationDate"
    }
    
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var photos : [Photo]
    
    dynamic var coordinate : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude),
                longitude: CLLocationDegrees(longitude))
        }
        set(coord)  {
            latitude = coord.latitude
            longitude = coord.longitude
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary : [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        latitude = dictionary["Latitude"] as! Double
        longitude = dictionary["Longitude"] as! Double
    }
    
}