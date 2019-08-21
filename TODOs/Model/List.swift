//
//  List.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

@objc (List)
class List: NSManagedObject {
    
    func set(name: String) {
//        do { try Menu.common.realm.write { self.name = name }
//        } catch let err { fatalError(err.localizedDescription)}
    }
    
    func remove(todo: Todo) {
        AppDelegate.viewContext.delete(todo)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
}
