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
    @objc dynamic var name: String = ""
    var todos = RealmSwift.List<Todo>()
    
    func add(_ newTodo: Todo) {
        do { try Menu.common.realm.write { todos.append(newTodo) }
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(name: String) {
        do { try Menu.common.realm.write { self.name = name }
        } catch let err { fatalError(err.localizedDescription)}
    }
    
    func remove(_ todo: Todo) {
        do { try Menu.common.realm.write { Menu.common.realm.delete(todo) }
        } catch let err { fatalError(err.localizedDescription) }
    }
    
}
