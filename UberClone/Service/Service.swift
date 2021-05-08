//
//  Service.swift
//  UberClone
//
//  Created by Renato Mateus on 06/05/21.
//

import Foundation
import CoreLocation

struct Service {
    static let shared = Service()
    
    func fetchUserData(completion: @escaping(User) -> Void){
        var user:User
        let uid: String = UUID().uuidString
        let userSaved = UserDefaults.standard.object(forKey: "user") as? [String: String] ?? [String: String]()
        if userSaved.count > 0 {
            user = User(uid: uid, name: userSaved["name"] ?? "", email: userSaved["email"] ?? "", accountType: userSaved["accountType"] ?? "")
            completion(user)
        }
    }
    
    func fetchDrivers(completion: @escaping([User]) -> Void){
        var drivers: [User] = []
        let n: Int = 1
        for d in 1...n {
            let uid: String = UUID().uuidString
            let randomInt = Double(round(Double.random(in: 0.1..<0.9) * 1000) / 100000)
            guard let location = LocationHandler.shared.locationManger.location else {return}
            let manualLatitude : CLLocationDegrees = Double(location.coordinate.latitude + randomInt)
            let manualLongitude : CLLocationDegrees = Double(location.coordinate.longitude + randomInt)
            let driverLocation = CLLocation(latitude: manualLatitude, longitude: manualLongitude)
            
            let driver = User(uid: uid, name: "Driver \(d)", email: "driver\(d)@driver.com", accountType: "1", location: driverLocation)
            //print("From Driver Location \(location.coordinate.latitude) - \(location.coordinate.longitude)")
            //print("To Driver Location \(driverLocation.coordinate.latitude) - \(driverLocation.coordinate.longitude)")
            drivers.append(driver)
        }
        completion(drivers)
    }
    
    func updateAnnotation(withMe userLocation: CLLocation, drivers: [User], completion: @escaping([User]) -> Void){
        var driversAux: [User] = []
        //guard let userLocation = user.location else {return}
        for driver in drivers {
            guard let driverLoc = driver.location else {return}
            let randomInt = Double(round(Double.random(in: 0.1..<0.9) * 1000) / 1000)
            guard let location = LocationHandler.shared.locationManger.location else {return}
            let manualLatitude : CLLocationDegrees = Double(driverLoc.coordinate.latitude + randomInt)
            let manualLongitude : CLLocationDegrees = Double(driverLoc.coordinate.longitude + randomInt)
            let driverLocation = CLLocation(latitude: manualLatitude, longitude: manualLongitude)
            
            let driver = User(uid: driver.uid, name: driver.name, email: driver.email, accountType: driver.accountType, location: driverLocation)
            driversAux.append(driver)
            if driver.name == "Driver 4"{
                print("\(driverLocation.coordinate.latitude + randomInt)")
            }
        }
        
        completion(driversAux)
    }
}
