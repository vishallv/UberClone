//
//  Service.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/26/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {
    
    static let shared = Service()

    func fetchUserData(uid: String ,completion: @escaping(User)->Void){
       
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else{return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
            
        }
    }
    
    func fetchDrivers(location: CLLocation, completion : @escaping(User) -> Void ){
//        , completion : @escaping(User) -> Void
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
            
            
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in


//            print(location.coordinate)
//
//             geofire.query(at: location, withRadius: 50).observe(.keyEntered,with : { (uid, location) in
//                print("DEBUG: Sucess geofire...")
//                print(uid)
//                print(location.coordinate)
//            })
            
            geofire.query(at: location, withRadius: 50).observe(.keyEntered,with:  { (uid, driverLocation) in
                print("DEBUG: Sucess geofire...")
                print(uid)
                print(location.coordinate)
                
                
                self.fetchUserData(uid: uid) { (user) in
                    print("DEBUG: Sucess geofire")
                    var driver = user
                    driver.location = driverLocation
                    completion(driver)
                }

            })
        }
        
    }
}
