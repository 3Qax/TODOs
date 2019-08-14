//
//  MenuHeader.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class MenuHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    var styleAsCollapsed = false { didSet { styleAsCollapsed ? showAsCollapsed() : showAsExpanded() } }
    
    private func showAsCollapsed() {
        arrowImageView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] () in
            self?.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        })
    }
    private func showAsExpanded() {
        arrowImageView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] () in
            self?.arrowImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
}
