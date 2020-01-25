//
//  SignUpController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/24/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {
    
    //MARK: PROPERTIES
    
    private let titleLabel: UILabel = {
           let label = UILabel()
           label.text = "UBER"
           label.font = UIFont(name: "Avenir-light", size: 36)
           label.textColor = UIColor(white: 1, alpha: 0.8)
           return label
       }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextfield)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullNameContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNmaeTextfield)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x") ,segmentedControl: accountTypeSegmentControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextfield)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
       }()
    
    private let emailTextfield : UITextField = {
        return UITextField().textField(withPlaceholder: "Email",
                                       isSecureTextEntry: false)
    }()
    
    private let fullNmaeTextfield : UITextField = {
        return UITextField().textField(withPlaceholder: "FullName",
                                       isSecureTextEntry: false)
    }()
    
    private let passwordTextfield : UITextField = {
        return UITextField().textField(withPlaceholder: "Password",
                                       isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentControl : UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Rider","Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor.init(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpButton : AuthButton = {
           let button = AuthButton(type: .system)
           button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
           return button
       }()
    
    
    private let alreadyHaveAccountButton : UIButton  = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes:
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor :UIColor.lightGray ])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes:
            [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor :UIColor.mainBlueTint ]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    //MARK: LIFE CYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: SELECTORS
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: Helper Function
    
    
    func configureUI(){
           
           view.backgroundColor = .backgroundColor
           
           view.addSubview(titleLabel)
           titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
           titleLabel.centerX(inView: view)
           
           
           let stack = UIStackView(arrangedSubviews: [emailContainerView,fullNameContainerView,passwordContainerView,
                                                      accountTypeContainerView,signUpButton])
           stack.axis = .vertical
           stack.distribution = .fillProportionally
           stack.spacing = 24
           
           view.addSubview(stack)
           stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                        paddingTop: 40, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
           
           view.addSubview(alreadyHaveAccountButton)
           alreadyHaveAccountButton.centerX(inView: view)
           alreadyHaveAccountButton .anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,height: 32)
           
       }
}