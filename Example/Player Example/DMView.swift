//
//  DMView.swift
//  Player Example
//
//  Created by Yudhi SATRIO on 10/04/23.
//  Copyright © 2023 Dailymotion. All rights reserved.
//

import UIKit

class DMView: UIView {
    let subview = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(subview)
        subview.backgroundColor = .black
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            subview.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
}
