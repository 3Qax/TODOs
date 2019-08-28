//
//  TodoView.swift
//  TODOs
//
//  Created by Jakub Towarek on 04/09/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import WSTagsField

class TodoView: UIView {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    @IBOutlet weak var tagsField: WSTagsField!

    class func instanceFromNib() -> UIView {
        return UINib(nibName: TodoView.className, bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
