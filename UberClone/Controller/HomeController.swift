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
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private final let locationInputViewHeight : CGFloat = 200
    
    private var user : User? {
        didSet{
            
            locationInputView.user = user
        }
    }
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationService()
        fetchUserData()
        fetchDrivers()
//        signOut()
        
        
    }
    
    //MARK: API
    
    func fetchDrivers(){
        guard let location = locationManager?.location else{return}
//        Service.shared.fetchDrivers(location: location)
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else {return}
            print("DEBUG: Sucess annotation")
            print("DEBUG: Sucess annotation \(coordinate)")
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            
            self.mapView.addAnnotation(annotation)
//            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            
            
        }
    }
    
    func fetchUserData(){
        guard let currnetUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currnetUid) { (user) in
            self.user = user
        }
    }
    
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
            
            DispatchQueue.main.async {
                 let navController = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13, *){
                    navController.isModalInPresentation = true
                }
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
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
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
        
        
        
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
       
        
        view.addSubview(tableView)
    }
    
}



//MARK: LocationServices

extension HomeController {
    func enableLocationService(){
        
//        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus(){
            
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        case .authorizedAlways:
            print("authorized Always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("authorized When In Use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
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
            
            self.tableView.frame.origin.y = self.view.frame.height
           
        }) { _ in
//            print("remove table view")
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
             
        }
    }
    
    
}

//MARK: UITableViewDelegate

extension HomeController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        return cell
    }
    
    
}
