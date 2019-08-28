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

    // this functions generates fake list containing
    // all of the todos which have given tag assigned to them
    // it is neccessary to delete fake list created that way after going back from ListForTagVC
    static func generateFakeList(for tag: Tag) -> List {
        let newList = List(context: AppDelegate.viewContext)
        newList.title = tag.name
        newList.isForTag = true
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "ANY tags.name = %@", tag.name)
        newList.sortedTodos = NSFetchedResultsController(fetchRequest: request,
                                                         managedObjectContext: AppDelegate.viewContext,
                                                         sectionNameKeyPath: nil,
                                                         cacheName: nil)
        do { try newList.sortedTodos.performFetch()
        } catch let err { fatalError(err.localizedDescription) }
        return newList
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
