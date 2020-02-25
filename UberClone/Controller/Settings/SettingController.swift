//
//  SettingController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/22/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LocationCell"

enum LocationType: Int,CaseIterable,CustomStringConvertible{
    case home
    case work
    
    var description: String {
        switch self{
            
        case .home:
            return "Home"
        case .work:
            return "Work"
        
        }
    }
    
    var subTitle: String {
        switch self{
            
        case .home:
            return "Add Home"
        case .work:
            return "Add Work"
        
        }
    }
}

protocol SettingControllerDelegate : class{
    func updateUser(_ controller: SettingController)
}

class SettingController : UITableViewController{
    
    //MARK: Properties
    weak var delegate: SettingControllerDelegate?
    var user : User
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var infoHeader : UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    var userInfoUpdated = false
    
    //MARK: Life Cycles
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        configureTableView()
        configureNavigationBar()
    }
    
    //MARK: Selectors
    @objc func handleDismiss(){
        if userInfoUpdated{
            delegate?.updateUser(self)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Helper Functions
    
    func locationText(forType type: LocationType)-> String{
        
        switch type{
            
        case .home:
            return user.homeLocation ?? type.subTitle
        case .work:
            return user.workLocation ?? type.subTitle
        
        }
    }
    
    func configureTableView(){
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
        
    }
    func configureNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
}

//MARK: UItableViewDelegate
extension SettingController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black

        let title = UILabel()
        title.textColor = .backgroundColor
        title.font = UIFont.systemFont(ofSize: 16)
        title.text = "Favourites"
        view.addSubview(title)
        title.centerY(inView: view, constant: 0, leftAnchor: view.leftAnchor, paddingLeft: 16)

        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        guard let option = LocationType(rawValue: indexPath.row) else{return cell}
        
//        cell.type = option
        cell.titleLabel.text = option.description
        cell.addressLabel.text = locationText(forType: option)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = LocationType(rawValue: indexPath.row) else{ return }
        guard let location = locationManager?.location else {return}
        let controller = AddLocationController(type: option, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
}

//MARK: AddLocationControllerDelegate
extension SettingController : AddLocationControllerDelegate{
    func updateLocation(locationString: String, type: LocationType) {
        
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
            
            self.userInfoUpdated = true
            switch type{
                
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
        
            }
            self.tableView.reloadData()
        }
    }
    
    
}
