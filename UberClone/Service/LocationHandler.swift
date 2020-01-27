//
//  LocationHandler.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/26/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import CoreLocation

class LocationHandler : NSObject,CLLocationManagerDelegate{
    
    static let shared = LocationHandler()
    var locationManager : CLLocationManager!
    var location : CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
}
