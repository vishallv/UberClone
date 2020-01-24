//
//  LoginController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/24/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//


import UIKit

class LoginController: UIViewController{
    
    //MARK: Propperties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    //MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:0).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
