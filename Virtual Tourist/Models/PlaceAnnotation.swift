//
//  PlaceAnnotation.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/27/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: MKPointAnnotation {
    var pin: Pin
    
    init(_ pin: Pin) {
        self.pin = pin
        super.init()
    }
}
