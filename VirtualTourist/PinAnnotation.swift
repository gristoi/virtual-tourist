//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 09/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class PinAnnotation:NSObject, MKAnnotation {
    
    private var coord : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:0, longitude:0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }

}
