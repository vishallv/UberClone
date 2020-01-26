//
//  HomeController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/25/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase
import MapKit
class HomeController : UIViewController{
    
    //MARK: Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationService()
//        signOut()
        
        
    }
    
    //MARK: API
    
    func checkIfUserIsLoggedIn(){
        
        if Auth.auth().currentUser?.uid == nil{
            
            DispatchQueue.main.async {
                 let navController = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13, *){
                    navController.isModalInPresentation = true
                }
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
           
        }
        else{
           configureUI()
        }
        
    }
    
    func signOut(){
        
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("Error to sign out user")
        }
    }
    
    //MARK: Hnadlers
    
    
    //MARK: Helper Functions
    
    func configureUI(){
        configureMapView()
        
    }
    
    func configureMapView(){
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
}

//MARK: LocationServices

extension HomeController: CLLocationManagerDelegate {
    func enableLocationService(){
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus(){
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("authorized Always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("authorized When In Use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
}
