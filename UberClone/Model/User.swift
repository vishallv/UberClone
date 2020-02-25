//
//  User.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/26/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import CoreLocation

enum AccountType:Int {
    
    case passenger
    case driver
}

struct User{
    
    let fullname:String
    let email: String
    var accountType : AccountType!
    let uid : String
    var location : CLLocation?
    var homeLocation : String?
    var workLocation: String?
    
    var firstInitial : String { return String(fullname.prefix(1))}
    
    init(uid:String ,dictionary: [String:Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let home  = dictionary["homeLocation"] as? String {
            
            self.homeLocation = home
        }
        if let work  = dictionary["workLocation"] as? String {
            
            self.workLocation = work
        }
        
        if let index = dictionary["accountType"] as? Int{
            
            self.accountType = AccountType(rawValue: index)!
        }
    }
}
