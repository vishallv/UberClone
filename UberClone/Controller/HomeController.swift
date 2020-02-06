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
private let annotationIdentifier = "DriverAnnotation"

private enum ActionbuttonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController : UIViewController{
    
    //MARK: Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var actioonButtonConfig = ActionbuttonConfiguration()
    private var route : MKRoute?
    
    private final let locationInputViewHeight : CGFloat = 200
    private final let rideActionViewHeight : CGFloat = 300
    
    
    private var user : User? {
        didSet{
            
            locationInputView.user = user
            if user?.accountType == .passenger{
                fetchDrivers()
                configureLocationActivationView()
            }
            else{
                observeTrips()
            }
        }
    }
    
    private var trip : Trip?{
        didSet{
            guard let trip = trip else {return}
            
            let controller = PickUpController(trip: trip)
            
            if #available(iOS 13, *){
                controller.isModalInPresentation = true
            }
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationService()

//        signOut()
        
        
    }
    
    //MARK: API
    
    func fetchDrivers(){

        guard let location = locationManager?.location else{return}
//        Service.shared.fetchDrivers(location: location)
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else {return}
//            print("DEBUG: Sucess annotation")
//            print("DEBUG: Sucess annotation \(coordinate)")
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            
            var driverIsVisible : Bool {
                
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    
                    guard let driverAnnotation = annotation as? DriverAnnotation else{return false}
                    
                    if driverAnnotation.uid == driver.uid{
                        //Update location
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    
                        return false
                    
                }
                
            }
            
            if !driverIsVisible{
                self.mapView.addAnnotation(annotation)
            }
            
            
//            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            
            
        }
    }
    func observeTrips(){
        
        Service.shared.observeTrips { (trip) in
            self.trip = trip
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
          configure()
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
    
    
    @objc func actionButtonPressed(){
        switch actioonButtonConfig{
            
        case .showMenu:
            print("DEBUG Show Menu")
        case .dismissActionView:
           removeAnnotationAndOverlay()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
           
        }
    }
    
    //MARK: Helper Functions
    
    func configure(){
        configureUI()
        fetchUserData()
//        fetchDrivers()
        
    }
    
   fileprivate func configureActionButton(config: ActionbuttonConfiguration){
       switch config{
           
       case .showMenu:
           self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
           self.actioonButtonConfig = .showMenu
       case .dismissActionView:
           actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
           actioonButtonConfig = .dismissActionView
           
   }
    }
    
    func configureUI(){
        configureMapView()
        configureRideActionView()
        view.addSubview(actionButton)
        actionButton.anchor(top:view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 20,paddingLeft: 16,width: 30,height: 30)
        
        configureTableView()
    }
    
    func configureLocationActivationView(){
        view.addSubview(inputActivationView)
               inputActivationView.centerX(inView: view)
               inputActivationView.setDimensions(height: 50, width: view.frame.width-64)
               inputActivationView.anchor(top:actionButton.bottomAnchor,paddingTop: 32)
               inputActivationView.alpha = 0
               inputActivationView.delegate = self
               UIView.animate(withDuration: 2) {
                   self.inputActivationView.alpha = 1
               }
    }
    
    func configureMapView(){
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
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
    
    func configureRideActionView(){
        rideActionView.delegate = self
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: rideActionViewHeight)
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
    
    func dismissLocationView(completion : ((Bool) -> Void)? = nil){
      
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
            
                }, completion: completion)
            }
    
    func animateRideActionView(shouldShow: Bool,destination : MKPlacemark? = nil){
        
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        if shouldShow {
            guard let destination = destination else {return}
            rideActionView.destination = destination
            
        }
      
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = yOrigin
            }
       
        
    }
    
    
}

//MARK: Map Helper function

private extension HomeController{
 
    func searchBy(naturalLanguageQuery : String , completion : @escaping([MKPlacemark])->Void){
        
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {return}
            
            response.mapItems.forEach { item in
            
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination : MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationAndOverlay(){
        
        mapView.annotations.forEach { (annotation) in
            if let annotation  = annotation as? MKPointAnnotation{
            mapView.removeAnnotation(annotation)
            }
        }
        if mapView.overlays.count > 0{
            
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}



//MARK: MkMapviewDelagate

extension HomeController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
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
    func executeSearch(query: String) {
        
        searchBy(naturalLanguageQuery: query) { (placemark) in
            self.searchResults = placemark
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        
        dismissLocationView { (_) in
            UIView.animate(withDuration: 0.5) {
            self.inputActivationView.alpha = 1
            }
        }
//        UIView.animate(withDuration: 0.3, animations: {
//            self.locationInputView.alpha = 0
//
//            self.tableView.frame.origin.y = self.view.frame.height
//
//        }) { _ in
////            print("remove table view")
//            self.locationInputView.removeFromSuperview()
//            UIView.animate(withDuration: 0.3) {
//                self.inputActivationView.alpha = 1
//            }
//
//        }
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
        
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1{
            
        cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaceMark = searchResults[indexPath.row]
//        var annotations = [MKAnnotation]()

        self.configureActionButton(config: .dismissActionView)
        let destination = MKMapItem(placemark: selectedPlaceMark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { _ in
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlaceMark.coordinate
            
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
//            self.mapView.annotations.forEach { (annotation) in
//                if let anno = annotation as? MKUserLocation{
//                    annotations.append(anno)
//                }
//
//                if let anno = annotation as? MKPointAnnotation{
//                    annotations.append(anno)
//                }
//            }
            
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self)})
            
//            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            self.animateRideActionView(shouldShow: true,destination: selectedPlaceMark)
        }
        
        
    }
    
    
}

//MARK: RideActionViewDelegate
extension HomeController : RideActionViewDelegate{
    func uploadTrip(_ view: RideActionView) {
        guard let pickUpCoordinate = locationManager?.location?.coordinate else {return}
        guard let destiantionCoordinate = view.destination?.coordinate else {return}
        Service.shared.uploadTrip(pickUpCoordinate, destiantionCoordinate) { (error, ref) in
            if let error = error{
                
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            print("Uploaded to DB Succes")
        }
    }
    
    
    
}
