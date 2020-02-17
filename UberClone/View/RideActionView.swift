//
//  RideActionView.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/29/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import MapKit
protocol RideActionViewDelegate: class {
    
    func uploadTrip(_ view :RideActionView)
    func cancelTrip()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickUpPassenger
    case tripInProgress
    case endTrip
    
    init(){
        self = .requestRide
    }
}

enum ButtonAction :CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickUp
    case dropOff
    
    var description : String{
        switch self {
            
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickUp:
            return "PICK UP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        
       
        }
    }
    init(){
        self = .requestRide
    }
}

class RideActionView: UIView {

   //MARK: Properties
    
    weak var delegate : RideActionViewDelegate?
    
    var buttonAction = ButtonAction()
    var user : User?
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config)}
    }
    
    var destination : MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    private let titleLabel : UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
//        label.text = "Test address label"
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel : UILabel = {
        
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
//        label.text = "Test address address"
        return label
    }()
    
    private lazy var infoView : UIView = {
        let view = UIView()
        view.backgroundColor =  .black
        
        
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()
    
    private let infoViewLabel : UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberInfoLabel : UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "UBER X"
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor,paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor , paddingTop: 16,width: 60,height: 60)
        infoView.layer.cornerRadius = 60/2
        
        addSubview(uberInfoLabel)
        uberInfoLabel.centerX(inView: self)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        
        let seperatorView  = UIView()
        seperatorView.backgroundColor = .lightGray
        addSubview(seperatorView)
        seperatorView.anchor(top:uberInfoLabel.bottomAnchor,left: leftAnchor,right: rightAnchor,paddingTop: 4,
                             height: 0.75)
        
        addSubview(actionButton)
        actionButton.centerX(inView: self)
        actionButton.anchor(left: leftAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,right: rightAnchor,
                            paddingLeft: 12,paddingBottom: 12,paddingRight: 12,height: 50)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
    @objc func actionButtonPressed(){
        switch buttonAction {
            
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("Handle getDirections")
        case .pickUp:
            print("Handle pickUp")
        case .dropOff:
            print("Handle dropOff")
       
    }
    }
    
//MARK: HelperFuction
    
    private func configureUI(withConfig config : RideActionViewConfiguration){
        
        switch config{
            
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else {return}
            
            if user.accountType == .passenger{
                titleLabel.text = "En Route To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            else{
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
        case .pickUpPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickUp
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripInProgress:
            
            guard let user = user else{return}
            
            if user.accountType == .driver{
                actionButton.setTitle("Trip In Progress", for: .normal)
                actionButton.isEnabled = false
            }else{
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "On Route To Destination"
            
        case .endTrip:
            guard let user = user else {return}
            if user.accountType == .driver{
            
                actionButton.setTitle("Arrived At Destination", for: .normal)
                actionButton.isEnabled = false
            }
            else{
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    
        }
        
    

}
