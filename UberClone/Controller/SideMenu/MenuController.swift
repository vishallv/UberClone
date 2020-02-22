//
//  MenuController.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/21/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MenuCell"

 enum MenuOption : Int, CaseIterable, CustomStringConvertible{
    case yourTrips
    case settings
    case logOut
    
    var description: String{
        
        switch self{
            
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logOut: return "Log Out"
        }
    }
}

protocol MenuControllerDelegate : class{
    func didSelect(option : MenuOption)
}

class MenuController : UITableViewController{
    
    //MARK: Properties
    weak var delegate : MenuControllerDelegate?
    
    private lazy var menuHeader : MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        
        let view = MenuHeader(user: user, frame: frame)
        return view
    }()
    
    private let user : User
//     var user : User? {
//        didSet{
//            guard let user = user else {return}
//            menuHeader.user = user
//        }
//    }
    //MARK: Life Cycles
    
    init(user : User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        
    }
    
    //MARK: Selectors
    
    //MARK: Helper Functions
    
    func configureTableView(){
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
        
    }
}

extension MenuController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOption.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
//        cell.textLabel?.text = "Menu option"
        
        guard let option = MenuOption(rawValue: indexPath.row) else{return UITableViewCell()}
        cell.textLabel?.text = option.description
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let option = MenuOption(rawValue: indexPath.row) else {return}
        delegate?.didSelect(option: option)
    }
}
