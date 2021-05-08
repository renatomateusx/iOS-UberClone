//
//  LocationHandler.swift
//  UberClone
//
//  Created by Renato Mateus on 07/05/21.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationHandler()
    
    var locationManger: CLLocationManager!
    var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            locationManger.requestAlwaysAuthorization()
        }
    }
}
