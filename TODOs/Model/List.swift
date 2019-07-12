//
//  List.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import RealmSwift

class List: Object {
    @objc dynamic private(set) var name: String = ""
    let todos = RealmSwift.List<Todo>()
}
