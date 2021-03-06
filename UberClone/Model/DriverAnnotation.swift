//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/27/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import MapKit

class DriverAnnotation :NSObject,MKAnnotation{
    dynamic var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(uid: String , coordinate : CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordiante : CLLocationCoordinate2D){
        
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordiante
        }
    }
    
    
}
