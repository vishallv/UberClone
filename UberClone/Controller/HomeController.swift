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
private let reuseIdentifier = "LocationCell"

class HomeController : UIViewController{
    
    //MARK: Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private final let locationInputViewHeight : CGFloat = 200
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
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width-64)
        inputActivationView.anchor(top:view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
    }
    
    func configureMapView(){
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func configureLocationInputView(){
        
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,height: locationInputViewHeight)
        
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            
            print("present table view")
        }
        
        
        
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.rowHeight = 60
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
       
        
        view.addSubview(tableView)
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


//MARK: LocationInputActivationViewDelegate
extension HomeController : LocationInputActivationViewDelegate{
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
}

//MARK: LocationInputViewDelegate

extension HomeController : LocationInputViewDelegate{
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
           
        }) { _ in
//            print("remove table view")
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
             
        }
    }
    
    
}

extension HomeController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        return cell
    }
    
    
}
