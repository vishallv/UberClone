//
//  MenuHeader.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/21/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit




class MenuHeader : UIView{
    //MARK: Properties
    
//    var user : User? {
//        didSet{
//            fullnameLabel.text = user?.fullname
//            emailLabel.text = user?.email
//        }
//    }
    
    private let user : User
    
    private let profileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var fullnameLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
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
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,left: leftAnchor,
                                paddingTop: 4,paddingLeft: 4,
                                width: 64,height: 64)
        profileImageView.layer.cornerRadius = 32
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel,emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        
//        
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Selectors
    
    //MARK: Helper Functions
}
