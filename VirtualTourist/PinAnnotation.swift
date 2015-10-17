//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 09/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import MapKit

class PinAnnotation: MKPointAnnotation {
    
    var pin:Pin! {
        didSet {
            coordinate = pin.coordinate
        }
    }
    
    convenience init(_ pin:Pin) {
        self.init()
        self.setValue(pin, forKey: "pin")
    }
}
