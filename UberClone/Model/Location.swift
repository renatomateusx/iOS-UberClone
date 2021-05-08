//
//  Driver.swift
//  UberClone
//
//  Created by Renato Mateus on 07/05/21.
//

import Foundation
struct Location: Codable {
    var latitude: Double
    var longitude: Double
    
    init(withName name:String, email:String, accountType: String){
        self.name = name
        self.email = email
        self.accountType = accountType
    }
}
