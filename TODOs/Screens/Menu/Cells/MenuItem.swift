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
    func shouldEndEditing(sender: MenuItem) -> Bool
}

/// Cell isplayed in MenuView's tableView. Represents list.
class MenuItem: UITableViewCell {

    @IBOutlet weak var titleTextView: UITextView!

    weak var delegate: MenuItemDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

}

extension MenuItem: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // when user taps return asks delegate whether or not it should end editing
        if text == "\n" {
            if let shouldEndEditing = delegate?.shouldEndEditing(sender: self) {
                self.titleTextView.isEditable =  !shouldEndEditing
            } else {
                self.titleTextView.isEditable =  false
            }
            return false
        }

        // informs delegate that the entered title has changed
        delegate?.textChanged()

        return true

    }

}
