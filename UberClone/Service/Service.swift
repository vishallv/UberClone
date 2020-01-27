//
//  Service.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/26/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {
    
    static let shared = Service()

    func fetchUserData(completion: @escaping(User)->Void){
        guard let currentUid = Auth.auth().currentUser?.uid else{return}
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else{return}
            let user = User(dictionary: dictionary)
            
            completion(user)
            
        }
    }
}
