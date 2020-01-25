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
class HomeController : UIViewController{
    
    //MARK: Properties
    
    private let mapView = MKMapView()
    
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
//        signOut()
        
        
    }
    
    //MARK: API
    
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
           configureUI()
        }
        
    }
    
    func signOut(){
        
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("Error to sign out user")
        }
    }
    
    //MARK: Hnadlers
    
    
    //MARK: Helper Functions
    
    func configureUI(){
        
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    
}
