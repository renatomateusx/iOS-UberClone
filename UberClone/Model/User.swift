//
//  User.swift
//  UberClone
//
//  Created by Renato Mateus on 06/05/21.
//

import Foundation
import CoreLocation

struct User {
    var uid: String
    var name: String
    var email: String
    var accountType: String
    var location: CLLocation?
    
    init(uid: String, name:String, email:String, accountType: String, location: CLLocation? = nil){
        self.uid = uid
        self.name = name
        self.email = email
        self.accountType = accountType
        
        if let location = location {
            self.location = location
        }
    }
}
