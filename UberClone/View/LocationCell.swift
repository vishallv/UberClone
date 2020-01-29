//
//  LocationCell.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 1/26/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

   //MARK: Properties
    
    var placemark : MKPlacemark? {
        didSet{
//            guard let placemark = placemark else {return}
            titleLabel.text = placemark?.name
             addressLabel.text = placemark?.address
        }
    }
    
    private let titleLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let addressLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
   //MARK: Lifr Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self,leftAnchor: leftAnchor,paddingLeft: 12)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
