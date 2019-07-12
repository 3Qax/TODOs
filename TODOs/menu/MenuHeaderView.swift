//
//  MenuHeaderView.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

protocol MenuHeaderDelegate: AnyObject {
    func didTapHeader(sender: MenuHeaderView)
}
class MenuHeaderView: UITableViewCell {
    
    enum Category {
        case lists
        case tags
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    weak var delegate: MenuHeaderDelegate?
    
    func setup(as category: Category) {
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(MenuHeaderView.tapHandler))
        tgr.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tgr)
        
        switch category {
        case .lists:
            titleLabel.text = "Lists"

        case .tags:
            titleLabel.text = "Tags"
        }
        
    }
    
    @objc func tapHandler() {
        print("dupaaaa")
        delegate?.didTapHeader(sender: self)
    }
    
}
