//
//  MenuItem.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

protocol MenuItemDelegate: AnyObject {
    func textChanged()
    func didEndEditingListName(sender: MenuItem)
}
class MenuItem: UITableViewCell {

    @IBOutlet weak var titleTextView: UITextView!
    weak var delegate: MenuItemDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

extension MenuItem: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.titleTextView.isEditable = false
            delegate?.didEndEditingListName(sender: self)
            return false
        }
        delegate?.textChanged()
        return true
    }

}