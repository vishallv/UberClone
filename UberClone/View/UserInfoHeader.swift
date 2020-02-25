//
//  UserInfoHeader.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/22/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class UserInfoHeader : UIView{
    
    //MARK: Properties
    private let user : User
    
   private lazy var profileImageView : UIView = {
        let view = UIView()
        view.addSubview(initialLabel)
        initialLabel.centerX(inView: view)
        initialLabel.centerY(inView: view)
        
        
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var initialLabel : UILabel  = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42)
        label.textColor = .white
        label.text = user.firstInitial
        return label
        
    }()
       
       private lazy var fullnameLabel :UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 16)
           label.text = user.fullname
           return label
       }()
       
       private lazy var  emailLabel :UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 14)
           label.textColor = .lightGray
           label.text = user.email
           return label
       }()
    
    //MARK: Life Cycles
    
    init(user:User, frame: CGRect){
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
//        profileImageView.anchor(top: topAnchor,left: leftAnchor,
//                                paddingTop: 4,paddingLeft: 4,
//                                width: 64,height: 64)
        profileImageView.setDimensions(height: 64, width: 64)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        profileImageView.layer.cornerRadius = 32
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel,emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
    //MARK: Helper Functions
}
