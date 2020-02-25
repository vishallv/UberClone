//
//  Trip.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/30/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import CoreLocation

struct Trip {
    
    var pickUpCoordinates : CLLocationCoordinate2D!
    var destinatioCoordinates : CLLocationCoordinate2D!
    let passengerUid : String!
    var driverUid : String?
    var state : TripState!
    
    init(passengerUid :String , dictionary : [String:Any]) {
        self.passengerUid = passengerUid
        
        if let pickUpCoordiantes = dictionary["pickUpCoordinates"] as? NSArray {
           guard let lat = pickUpCoordiantes[0] as? CLLocationDegrees else { return }
           guard let long = pickUpCoordiantes[1] as? CLLocationDegrees else { return }
            
            self.pickUpCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinatioCoordinates = dictionary["destinationCoordinates"] as? NSArray {
                  guard let lat = destinatioCoordinates[0] as? CLLocationDegrees else { return }
                  guard let long = destinatioCoordinates[1] as? CLLocationDegrees else { return }
                   
                   self.destinatioCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
               }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int{
            self.state = TripState(rawValue: state)
        }
    }
    
}

enum TripState : Int{
    case requested
    case denied
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case completed
}
