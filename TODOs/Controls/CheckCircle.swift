//
//  CheckCircle.swift
//  TODOs
//
//  Created by Jakub Towarek on 14/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class CheckCircle: UIView {
    
    var isChecked = false {
        didSet {
            switch isChecked {
            case true:
                innerMask.isHidden = true
            case false:
                innerMask.isHidden = false
            }
        }
    }
    let innerMask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.cornerRadius = 11
        return view
    }()
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkGray
        self.cornerRadius = 25.0/2
        
        self.addSubview(innerMask)
        innerMask.translatesAutoresizingMaskIntoConstraints = false
        let innerMaskHeightContraint = innerMask.heightAnchor.constraint(equalToConstant: 22)
        let innerMaskWidthConstraint = innerMask.widthAnchor.constraint(equalToConstant: 22)
        let innerMaskCenterXConstraint = innerMask.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let innerMaskCenterYConstraint = innerMask.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.addConstraints([innerMaskHeightContraint,
                             innerMaskWidthConstraint,
                             innerMaskCenterXConstraint,
                             innerMaskCenterYConstraint])
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
}
