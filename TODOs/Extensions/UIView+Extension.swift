//
//  UIView+Extension.swift
//  TODOs
//
//  Created by Jakub Towarek on 13/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

extension UIView {

    /// Exposed IBDesignable property to allow live styling of
    /// views's corner radius in InterfaceBuilder
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0 ? true : false
        }
        get {
            return self.layer.cornerRadius
        }
    }

}
