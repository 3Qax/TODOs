//
//  Todo.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    @objc dynamic private(set) var title: String = ""
    @objc dynamic private(set) var isDone: Bool = false
    let tags = RealmSwift.List<Tag>()
    
    func set(title: String) {
        do { try Menu.common.realm.write { self.title = title }
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(isDone: Bool) {
        do { try Menu.common.realm.write { self.isDone = isDone }
        } catch let err { fatalError(err.localizedDescription) }
    }
}
