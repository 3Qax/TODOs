//
//  MenuView.swift
//  TODOs
//
//  Created by Jakub Towarek on 28/08/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

final class MenuView: UIView {

    @IBOutlet var tableView: UITableView!

    class func instanceFromNib() -> UIView {
        return UINib(nibName: MenuView.className, bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
