//
//  Service.swift
//  UberClone
//
//  Created by Renato Mateus on 06/05/21.
//

import Foundation

struct Service {
    static let shared = Service()
    
    func fetchUserData(completion: @escaping(User) -> Void){
        var user:User
        let userSaved = UserDefaults.standard.object(forKey: "user") as? [String: String] ?? [String: String]()
        if userSaved.count > 0 {
            user = User(withName: userSaved["name"] ?? "", email: userSaved["email"] ?? "", accountType: userSaved["accountType"] ?? "")
            completion(user)
        }
    }
}
