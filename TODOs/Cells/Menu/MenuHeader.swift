//
//  MenuHeader.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class MenuHeader: UITableViewHeaderFooterView {
    var tapAction: (() -> Void)?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    var styleAsCollapsed = false {
        didSet {
            if styleAsCollapsed { arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else { arrowImageView.transform = CGAffineTransform(rotationAngle: 0) }
        }
    }
    
    func onTap(action: @escaping () -> Void) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.addGestureRecognizer(tapGR)
        tapAction = action
    }
    @objc func tapHandler() {
        tapAction?()
    }
}
