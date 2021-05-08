//
//  LocationCell.swift
//  UberClone
//
//  Created by Renato Mateus on 05/05/21.
//

import UIKit
import MapKit

class LocationCell : UITableViewCell {
    
    // MARK: Properties
    var placeMark: MKPlacemark?
    
    
    static let identifier = "LocationCell"
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "148, Monsenhor F. P. Marques"
        return label
    }()
    
    private let addressLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "148, Monsenhor F. P. Marques, Salvador, Ba"
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers
    func configureView(){
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    func configure(withPlacemark placemark: MKPlacemark){
        self.placeMark = placemark
        
        self.titleLabel.text = placemark.name
        self.addressLabel.text = placemark.address
    }
    
    
}
