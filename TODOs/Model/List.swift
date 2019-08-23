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
    
    lazy var sortedTodos: NSFetchedResultsController<Todo> = {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "list == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true),
                                   NSSortDescriptor(key: "name", ascending: true)]
        let sortedTodos = NSFetchedResultsController(fetchRequest: request,
                                                 managedObjectContext: AppDelegate.viewContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
        do { try  sortedTodos.performFetch()
        } catch let err { fatalError(err.localizedDescription) }
        return sortedTodos
    }()
    
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

extension List {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }
    
    @NSManaged public var isForTag: Bool
    @NSManaged public var title: String
    @NSManaged public var todos: Set<Todo>
    
}

// MARK: Generated accessors for todos
extension List {
    
    @objc(addTodosObject:)
    @NSManaged public func addToTodos(_ value: Todo)
    
    @objc(removeTodosObject:)
    @NSManaged public func removeFromTodos(_ value: Todo)
    
    @objc(addTodos:)
    @NSManaged public func addToTodos(_ values: Set<Todo>)
    
    @objc(removeTodos:)
    @NSManaged public func removeFromTodos(_ values: Set<Todo>)
    
}
