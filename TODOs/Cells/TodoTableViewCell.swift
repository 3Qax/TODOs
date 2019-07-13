//
//  TodoTableViewCell.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func markAsDone() {
        outerCircle.isHidden = true
        outerCircle.isHidden = true
        checkImageView.isHidden = false
        checkImageView.tintColor = .lightGray
        nameLabel.textColor = .lightGray
        var textAttributes = [NSAttributedString.Key: Any]()
        textAttributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        textAttributes[NSAttributedString.Key.strikethroughColor] = UIColor.darkGray
        nameLabel.attributedText = NSAttributedString(string: nameLabel.text!, attributes: textAttributes)
    }

}
