//
//  User.swift
//  UberClone
//
//  Created by Renato Mateus on 06/05/21.
//

import Foundation


struct User: Codable {
    var name: String
    var email: String
    var accountType: String
    
    init(withName name:String, email:String, accountType: String){
        self.name = name
        self.email = email
        self.accountType = accountType
    }
}
