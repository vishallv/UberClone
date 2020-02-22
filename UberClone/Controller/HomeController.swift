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

private enum AnnotationType : String{
    case pickUp
    case destination
}

protocol HomeControllerDelegate : class{
    func handleMenuToggle()
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
    
    weak var delegate : HomeControllerDelegate?
    
    
     var user : User? {
        didSet{
            
            locationInputView.user = user
            if user?.accountType == .passenger{
                fetchDrivers()
                configureLocationActivationView()
                observeCurrentTrip()
            }
            else{
                observeTrips()
            }
        }
    }
    
    private var trip : Trip?{
        didSet{
            guard let user = user else {return}
            
            if user.accountType == .driver{
                guard let trip = trip else {return}
                
                let controller = PickUpController(trip: trip)
                controller.delegate = self
                if #available(iOS 13, *){
                    controller.isModalInPresentation = true
                }
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            }
            else{
                print("Show ride acceted")
            }
        }
    }
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    //MARK: Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else {return}
//        print(trip.state)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        checkIfUserIsLoggedIn()
        enableLocationService()
        configureUI()

//        signOut()
        
        
    }
    
    //MARK: Passenger API
    
    func observeCurrentTrip(){
        
        PassengerService.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            guard let state = trip.state else {return}
            guard let driverUid = trip.driverUid else {return}
            
            switch state {
                
            case .requested:
                break
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationAndOverlay()
                
                self.zoomForActiveTrip(withDriverUid: driverUid)
                Service.shared.fetchUserData(uid: driverUid) { (driver) in
                     self.animateRideActionView(shouldShow: true, config: .tripAccepted,
                                                user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                
                
                PassengerService.shared.deleteTrip { (erre, ref) in
                   
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.presentAlertController(withMessage: "Trip Completed", withTitle: "We hope you had a nice trip!!")
                }
           
            }
   
        }
    }
    
    func startTrip(){
        guard let trip = self.trip else {return}
        
        Service.shared.updateTripState(trip: trip, state: .inProgress) { (err, ref) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationAndOverlay()
            self.mapView.addAndSelectAnnotation(forCoordinate: trip.destinatioCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinatioCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            self.setCustomRegion(withType: .destination, coordinates: trip.destinatioCoordinates)
            self.generatePolyline(toDestination: mapItem)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    func fetchDrivers(){

        guard let location = locationManager?.location else{return}
//        Service.shared.fetchDrivers(location: location)
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
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
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
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
    
    //MARK: Driver API
    func observeTrips(){
        
        DriverService.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    //MARK: Shared API
    
//    func fetchUserData(){
//        guard let currnetUid = Auth.auth().currentUser?.uid else {return}
//        Service.shared.fetchUserData(uid: currnetUid) { (user) in
//            self.user = user
//        }
//    }
    
//    func checkIfUserIsLoggedIn(){
//
//        if Auth.auth().currentUser?.uid == nil{
//
//            DispatchQueue.main.async {
//                 let navController = UINavigationController(rootViewController: LoginController())
//                if #available(iOS 13, *){
//                    navController.isModalInPresentation = true
//                }
//                navController.modalPresentationStyle = .fullScreen
//                self.present(navController, animated: true, completion: nil)
//            }
//
//        }
//        else{
//          configure()
//        }
//
//    }
    
   
    
    //MARK: Hnadlers
    
    
    @objc func actionButtonPressed(){
        switch actioonButtonConfig{
            
        case .showMenu:
            delegate?.handleMenuToggle()
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
    
//    func configure(){
//        configureUI()
////        fetchUserData()
////        fetchDrivers()
//        
//    }
    
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
    
    func animateRideActionView(shouldShow: Bool,destination : MKPlacemark? = nil,config: RideActionViewConfiguration? = nil,
                               user: User? = nil){
        
        //Remove this code if it causes problem later
//        rideActionView.destination = nil
        
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        UIView.animate(withDuration: 0.3) {
                       self.rideActionView.frame.origin.y = yOrigin
                   }
        
        if shouldShow {
            guard let config = config else {return}
           
            
            
            if let destination = destination {
            rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
        rideActionView.config = config
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
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else{return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
        
    }
    
    func setCustomRegion(withType type : AnnotationType, coordinates :CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinates, radius: 100, identifier: type.rawValue)
        print("Strated monitering")
        locationManager?.startMonitoring(for: region)
    }
    
    func zoomForActiveTrip(withDriverUid uid : String){
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? DriverAnnotation{
                if anno.uid == uid{
                    annotations.append(anno)
                }
                
                
            }
            if let userAnno = annotation as? MKUserLocation{
                annotations.append(userAnno)
            }
        }
        
//        print("DEBUG: \(annotations)")
        self.mapView.zoomToFit(annotations: annotations)
    }
}



//MARK: MkMapviewDelagate

extension HomeController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else {return}
        guard user.accountType == .driver else{return}
        guard let location = userLocation.location else {return}
        Service.shared.updateDriverLocation(location: location)
    }
    
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

//MARK: CLLocationManagerDelegate

extension HomeController :CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickUp.rawValue{
        print("Debug: pick up region start \(region)")
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("Debug: destination region start \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Didi enter the Passenger region")
        guard let trip = self.trip else {return}
        
        if region.identifier == AnnotationType.pickUp.rawValue{
        Service.shared.updateTripState(trip: trip, state: .driverArrived) { (error, ref) in
            self.rideActionView.config = .pickUpPassenger
        }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("Debug: destination region start \(region)")
            
            Service.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { (error, ref) in
                self.rideActionView.config = .endTrip
            }
        }
        
        
    }
    
    func enableLocationService(){
        
        locationManager?.delegate = self
        
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
            
            self.mapView.addAndSelectAnnotation(forCoordinate: selectedPlaceMark.coordinate)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = selectedPlaceMark.coordinate
//
//            self.mapView.addAnnotation(annotation)
//            self.mapView.selectAnnotation(annotation, animated: true)
            
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
            self.animateRideActionView(shouldShow: true,destination: selectedPlaceMark,config: .requestRide)
        }
        
        
    }
    
    
}

//MARK: RideActionViewDelegate
extension HomeController : RideActionViewDelegate{
    func dropOffPassenger() {
        guard let trip = self.trip else {return}
        
        Service.shared.updateTripState(trip: trip, state: .completed) { (err, ref) in
            self.removeAnnotationAndOverlay()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
    func pickUpPassenger() {
        startTrip()
    }
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error{
                print("Debug: Error deleting trip... \(error.localizedDescription)")
                return
            }
            
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationAndOverlay()
            
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actioonButtonConfig = .showMenu
            
            self.inputActivationView.alpha = 1
            
        }
    }
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickUpCoordinate = locationManager?.location?.coordinate else {return}
        guard let destiantionCoordinate = view.destination?.coordinate else {return}
        
        shouldPresentLoadingView(true, message: "Finding you a ride")
        PassengerService.shared.uploadTrip(pickUpCoordinate, destiantionCoordinate) { (error, ref) in
            if let error = error{
                
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.animateRideActionView(shouldShow: false)
            }
//            print("Uploaded to DB Succes")
        }
    }
    
    
    
}

//MARK: PickUpControllerDelegate

extension HomeController : PickUpControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        
//        self.trip?.state = .accepted
        self.trip = trip
//        let anno = MKPointAnnotation()
//        anno.coordinate = trip.pickUpCoordinates
//        mapView.addAnnotation(anno)
//        mapView.selectAnnotation(anno, animated: true)
        mapView.addAndSelectAnnotation(forCoordinate: trip.pickUpCoordinates)
        
        
        setCustomRegion(withType: .pickUp, coordinates: trip.pickUpCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickUpCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        DriverService.shared.observeTripCancelled(trip: trip) {
            
            self.removeAnnotationAndOverlay()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withMessage: "The Passenger has cancelled the trip", withTitle: "Oops!")
//            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            
        }
        
        self.dismiss(animated: true) {
            
            Service.shared.fetchUserData(uid: trip.passengerUid) { (user) in
                self.animateRideActionView(shouldShow: true,config: .tripAccepted,
                                           user: user)
            }
            
        }
    }
    
    
}



