//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by Renato Mateus on 07/05/21.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    static let identifier = "DriverAnnotation"
    var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(withUID uid: String, coordinate: CLLocationCoordinate2D){
        self.uid = uid
        self.coordinate = coordinate
    }
}
