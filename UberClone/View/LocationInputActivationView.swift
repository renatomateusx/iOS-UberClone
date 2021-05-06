//
//  LocationInputActivationView.swift
//  UberClone
//
//  Created by Renato Mateus on 05/05/21.
//

import UIKit

protocol LocationinputActivationViewDelegate: class {
    func presentLocationInpuView()
}

class LocationinputActivationView: UIView {
    //MARK: Properties
    weak var delegate: LocationinputActivationViewDelegate?
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel: UILabel = {
       let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers
    func configureView(){
        
        backgroundColor = .white
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInpuView))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
    //MARK: Selectors
    @objc func presentLocationInpuView(){
        delegate?.presentLocationInpuView()
    }
}
