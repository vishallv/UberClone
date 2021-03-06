//
//  PickUpController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/4/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import MapKit

protocol PickUpControllerDelegate : class{
    func didAcceptTrip(_ trip: Trip)
}

class PickUpController :UIViewController {
    
    //MARK: Properties
    
    weak var delegate : PickUpControllerDelegate?
    
    private lazy var circularProgressView : CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268/2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp,constant: 32)
        
        return cp
    }()
    
    private let mapView = MKMapView()
    var trip : Trip
    
    private let cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return button
    }()
    
    private let pickUpLAbel : UILabel = {
        let label = UILabel()
        label.text = "Would you like to pick up this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        
        return label
    }()
    
    private let acceptTripButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        
        return button
    }()
    
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //MARK: Selectors
    @objc func animateProgress(){
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 5, value: 0) {
           
            
            //few change in code to prevent bug
//            Service.shared.updateTripState(trip: self.trip, state: .denied) { (err, ref) in
//                 self.dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    @objc func handleDismissal(){
        Service.shared.updateTripState(trip: self.trip, state: .denied) { (err, ref) in
             self.dismiss(animated: true, completion: nil)
        }
//        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip(){
        DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    //MARK: Helper Function
    
    func configureMapView(){
       
        let region = MKCoordinateRegion(center: trip.pickUpCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = trip.pickUpCoordinates
//
//        mapView.addAnnotation(annotation)
//        mapView.selectAnnotation(annotation, animated: true)
        mapView.addAndSelectAnnotation(forCoordinate: trip.pickUpCoordinates)
    }
    
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,left: view.leftAnchor,
                            paddingLeft: 16,width: 40,height: 40 )
        
//        view.addSubview(mapView)
//        mapView.setDimensions(height: 270, width: 270)
//        mapView.layer.cornerRadius = 270/2
//        mapView.centerX(inView: view)
//        mapView.centerY(inView: view, constant: -200)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top:view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        
        view.addSubview(pickUpLAbel)
        pickUpLAbel.centerX(inView: view)
        pickUpLAbel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickUpLAbel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
    
    
    
}
