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
    var styleAsEnabled = true {
        didSet {
            if styleAsEnabled { arrowImageView.tintColor = .black
            } else { arrowImageView.tintColor = UIColor(red: 7/8, green: 7/8, blue: 7/8, alpha: 1) }
        }
    }
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
