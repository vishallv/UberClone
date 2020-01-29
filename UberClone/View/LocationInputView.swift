//
//  LocationInputView.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/25/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate : class {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {

  //MARK: Propperties
    
    var user : User? {
        
        didSet{
             titleLable.text = user?.fullname
        }
       
    }
    
    private let backButton : UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        
        return button
    }()
    
    
     private let titleLable : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let startLocationIndicationView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView : UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicationView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startLocationTextfield : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .groupTableViewBackground
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isEnabled = false
        
        let paddigView = UIView()
        paddigView.setDimensions(height: 30, width: 8)
        tf.leftView = paddigView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var destinationLocationTextfield : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        
        let paddigView = UIView()
        paddigView.setDimensions(height: 30, width: 8)
        tf.leftView = paddigView
        tf.leftViewMode = .always
        return tf
    }()
    
    weak var delegate : LocationInputViewDelegate?
    
  //MARK: LifeCycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        
        backgroundColor = .white
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44,
                          paddingLeft: 12,width: 24, height: 25)
        
        addSubview(titleLable)
        titleLable.centerY(inView: backButton)
        titleLable.centerX(inView: self)
        
        addSubview(startLocationTextfield)
        startLocationTextfield.anchor(top:backButton.bottomAnchor,left: leftAnchor,
                                      right: rightAnchor,paddingTop: 4,
                                      paddingLeft: 40,paddingRight: 40,
                                      height: 30)
        
        addSubview(destinationLocationTextfield)
        destinationLocationTextfield.anchor(top:startLocationTextfield.bottomAnchor,left: leftAnchor,
                                      right: rightAnchor,paddingTop: 12,paddingLeft: 40,
                                      paddingRight: 40,
                                      height: 30)
        
        addSubview(startLocationIndicationView)
        startLocationIndicationView.centerY(inView: startLocationTextfield,leftAnchor: leftAnchor,
                                            paddingLeft: 20)
        startLocationIndicationView.setDimensions(height: 6, width: 6)
        startLocationIndicationView.layer.cornerRadius = 6/2
        
        addSubview(destinationIndicationView)
        destinationIndicationView.centerY(inView: destinationLocationTextfield,leftAnchor: leftAnchor,
                                            paddingLeft: 20)
        destinationIndicationView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicationView)
        linkingView.anchor(top:startLocationIndicationView.bottomAnchor,bottom: destinationIndicationView.topAnchor,
                           paddingTop: 4,paddingBottom: 4,width: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: HANDLER
    
    @objc func handleBackTapped(){
        delegate?.dismissLocationInputView()
    }
    

}

//MARK: UITextFieldDelegate
extension LocationInputView : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let query = textField.text else {return false}
        
        delegate?.executeSearch(query: query)
        return true
    }
    
}
