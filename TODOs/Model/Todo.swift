//
//  Todo.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

class Todo: NSManagedObject {
    
    func set(title: String) {
//        do { try Menu.common.realm.write { self.title = title }
//        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(isDone: Bool) {
//        do { try Menu.common.realm.write { self.isDone = isDone }
//        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(tags: [String]) {
//        //adding, changing, removing tags should work when the following code is uncommented
//        //but it does not, since https://github.com/realm/realm-cocoa/issues/5528
//        do {
//            try Menu.common.realm.write { Menu.common.realm.delete(self.tags) }
//        } catch let err { fatalError(err.localizedDescription) }
//
//        do {
//            try Menu.common.realm.write {
//                tags.forEach({ self.tags.append(Tag(value: ["name": "\($0)"])) })
//            }
//        } catch let err { fatalError(err.localizedDescription) }
        
    }
}
