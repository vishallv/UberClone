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
let REF_TRIP = DB_REF.child("trips")

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

            
            geofire.query(at: location, withRadius: 50).observe(.keyEntered,with:  { (uid, driverLocation) in

                self.fetchUserData(uid: uid) { (user) in
//                    print("DEBUG: Sucess geofire")
                    var driver = user
                    driver.location = driverLocation
                    completion(driver)
                }

            })
        }
        
    }
    func uploadTrip(_ pickUpCoordinate: CLLocationCoordinate2D, _ destinationCoordinate : CLLocationCoordinate2D,
                    completion : @escaping(Error?, DatabaseReference)->Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        let pickUpArray = [pickUpCoordinate.latitude,pickUpCoordinate.longitude]
        let destinationArray = [destinationCoordinate.latitude,destinationCoordinate.longitude]
        
        let values = ["pickUpCoordinates": pickUpArray,
        "destinationCoordinates": destinationArray,
        "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIP.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func observeTrips(completion : @escaping(Trip) -> Void){
        
        REF_TRIP.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    
}
