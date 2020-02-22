//
//  ContainerController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/21/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class ContainerController: UIViewController{
    
    //MARK:  Properties
    
    private var user : User? {
        didSet{
            guard let user = user else {return}
            homeController.user = user
            configureMenuControlerr(withUser: user)
        }
    }
    
    private var menuController : MenuController!
    private let homeController  = HomeController()
    private var isExpanded = false
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80
    
    //MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configure()
        checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool{
        return isExpanded
        
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    //MARK: Selectors
    
    @objc func dismissMenu(){
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    //MARK : API
    
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
          configure()
        }
        
    }
    
    func fetchUserData(){
        guard let currnetUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currnetUid) { (user) in
            self.user = user
        }
    }
    
    func signOut(){
           
           do{
               try Auth.auth().signOut()
               
               DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: LoginController())
                   if #available(iOS 13, *){
                       navController.isModalInPresentation = true
                   }
                   navController.modalPresentationStyle = .fullScreen
                   self.present(navController, animated: true, completion: nil)
               }
           }
           catch{
               print("Error to sign out user")
           }
       }
    
    
    //MARK: Helper Functions
    func configure(){
        view.backgroundColor = .backgroundColor
        configureHomeController()
        fetchUserData()
    }
    
    func configureHomeController(){
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
        
    }
    
    func configureMenuControlerr(withUser user : User){
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlackView()
       
    }
    
    func configureBlackView(){
        blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool,completion: ((Bool) -> Void)? = nil){

        if shouldExpand{
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            },completion: nil)
            

        }
        else{
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
            
        }
        animateStatusBar()
    }
    
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}
//MARK: HomeControllerDelegate
extension ContainerController : HomeControllerDelegate{
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
    
    
}

extension ContainerController: MenuControllerDelegate{
    func didSelect(option: MenuOption) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { (_) in
            switch option{
                
            case .yourTrips:
                break
            case .settings:
                break
            case .logOut:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                    self.signOut()
                }))
                alert.addAction(UIAlertAction(title: "CAncel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
}
