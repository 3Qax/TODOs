//
//  MenuHeader.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

/// Header displayed in MenuView's tableView
final class MenuHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

    var shouldStyleAsEnabled = true {
        didSet { arrowImageView.tintColor =  shouldStyleAsEnabled ? .black : .lightGray }
    }

    var shouldStyleAsCollapsed = false {
        didSet { arrowImageView.transform = CGAffineTransform(rotationAngle: shouldStyleAsCollapsed ? CGFloat.pi : 0) }
    }

    // clousure to execute when header is tapped
    private var tapAction: (() -> Void)?

    override func awakeFromNib() {

        super.awakeFromNib()

        let bodyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bodyTapHandler))
        self.addGestureRecognizer(bodyTapGestureRecognizer)

    }

    /// Sets MenuHeader's tap callback
    /// - Parameter action: clousure to execute
    public func onTap(action: @escaping () -> Void) {
        tapAction = action
    }

    // Called on body tap. Executes tapAction if it is set.
    @objc private func bodyTapHandler() {
        tapAction?()
    }

}
