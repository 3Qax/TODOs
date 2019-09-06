//
//  NSObject+Extension.swift
//  TODOs
//
//  Created by Jakub Towarek on 27/08/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation

extension NSObject {

    /// Returns a String representation of a class name
    /// Can be used as a safe and class unique identifier
    static var className: String {
        return String(describing: self)
    }

}
