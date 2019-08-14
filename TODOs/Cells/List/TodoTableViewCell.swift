//
//  TodoTableViewCell.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

protocol TodoTableViewCellDelegate: AnyObject {
    func didTapCircle(sender: TodoTableViewCell)
}
class TodoTableViewCell: UITableViewCell {
    var shouldStypeAsDone = false {
        didSet {
            switch shouldStypeAsDone {
            case true:
                checkCircle.isChecked = true
                nameLabel.textColor = .lightGray
                var textAttributes = [NSAttributedString.Key: Any]()
                textAttributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                textAttributes[NSAttributedString.Key.strikethroughColor] = UIColor.darkGray
                nameLabel.attributedText = NSAttributedString(string: nameLabel.text!, attributes: textAttributes)
            case false:
                checkCircle.isChecked = false
                nameLabel.textColor = .black
                let textAttributes = [NSAttributedString.Key: Any]()
                nameLabel.attributedText = NSAttributedString(string: nameLabel.text ?? "", attributes: textAttributes)
            }
        }
    }
    weak var delegate: TodoTableViewCellDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkCircle: CheckCircle!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        checkCircle.tapGestureRecognizer.addTarget(self, action: #selector(handleCircleTap))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func handleCircleTap() {
        delegate?.didTapCircle(sender: self)
    }

}
